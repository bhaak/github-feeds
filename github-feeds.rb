#!/usr/bin/env ruby

require 'rss'
require 'net/http'
require 'json'
require 'optparse'
require 'fileutils'

pulls = false
owner = nil
repository = nil
directory = '.'

OptionParser.new do |parser|
  parser.separator "List last commits of all reachable git branches"
  parser.separator ""
  parser.separator "Options:"
  parser.on('-p', '--pulls',  'List pull requests instead of issues') { pulls = true }
  parser.on('-o', '--owner=OWNER', '') {|o| owner = o }
  parser.on('-r', '--repository=REPOSITORY', '') {|r| repository = r }
  parser.on('-d', '--directory=DIRECTORY', '') {|d| directory = d }
end.parse!

raise OptionParser::MissingArgument.new('--owner is required') if owner.nil?
raise OptionParser::MissingArgument.new('--repository is required') if repository.nil?

type = pulls ? 'pull request' : 'issue'
issues = pulls ? 'pulls' : 'issues'

url = "https://api.github.com/repos/#{owner}/#{repository}/#{issues}"
response = Net::HTTP.get(URI(url))
json = JSON.parse(response, symbolize_names: true)

feed = RSS::Rss.new("2.0")
channel = RSS::Rss::Channel.new

channel.title = "GitHub #{type}s for #{owner}/#{repository}"
channel.description = " "
channel.link = "https://github.com/#{owner}/#{repository}"
channel.lastBuildDate = DateTime.now.rfc2822

json.each {|data|
  item = RSS::Rss::Channel::Item.new
  next if data[:pull_request]

  item.title = data[:title]
  item.author = data[:user][:login]
  link = data[:html_url]
  item.link = link

  item.guid = RSS::Rss::Channel::Item::Guid.new
  item.guid.content = link
  item.guid.isPermaLink = true

  item.pubDate = DateTime.parse(data[:created_at]).rfc2822

  channel.items << item
}
feed.channel = channel

FileUtils.mkdir_p directory
File.open("#{directory}/#{owner}_#{repository}_#{type.gsub(' ', '_')}s.rss", "w") {|f| f.write(feed.to_s) }

