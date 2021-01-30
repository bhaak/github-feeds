This Ruby scripts writes issues or pull requests as RSS 2.0 files into a local directory.

## Usage

### Issues

The script writes the file `bhaak_vilistextum_issues.rss` with the issues of this repository.

```shell
ruby github-feeds.rb --owner bhaak --repository vilistextum
```

### Pull requests

The script writes the file `bhaak_vilistextum_pull_requests.rss` with the pull requests of this repository.

```shell
ruby github-feeds.rb --pulls --owner bhaak --repository vilistextum
```

### Output directory

The default output directory is the current directory.
The output directory can be changed with the --directory option.
