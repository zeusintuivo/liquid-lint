# Liquid-Lint

[![Gem Version](https://badge.fury.io/rb/liquid_lint.svg)](http://badge.fury.io/rb/liquid_lint)
[![Build Status](https://github.com/zeusintuivo/liquid-lint/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/zeusintuivo/liquid-lint/actions/workflows/test.yml?query=branch%3Amaster)
[![Code Climate](https://codeclimate.com/github/zeusintuivo/liquid-lint.svg)](https://codeclimate.com/github/zeusintuivo/liquid-lint)
[![Coverage Status](https://coveralls.io/repos/zeusintuivo/liquid-lint/badge.svg)](https://coveralls.io/r/zeusintuivo/liquid-lint)
[![Inline docs](http://inch-ci.org/github/zeusintuivo/liquid-lint.svg?branch=master)](http://inch-ci.org/github/zeusintuivo/liquid-lint)

`liquid-lint` is a tool to help keep your [Liquid](http://liquid-lang.com/) files
clean and readable. In addition to style and lint checks, it integrates with
[RuboCop](https://github.com/bbatsov/rubocop) to bring its powerful static
analysis tools to your Liquid templates.

You can run `liquid-lint` manually from the command line, or integrate it into
your [SCM hooks](https://github.com/brigade/overcommit).

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
* [Linters](#linters)
* [Editor Integration](#editor-integration)
* [Git Integration](#git-integration)
* [Rake Integration](#rake-integration)
* [Documentation](#documentation)
* [Contributing](#contributing)
* [Changelog](#changelog)
* [License](#license)

## Requirements

 * Ruby 2.4+
 * Liquid 3.0+

## Installation

```bash
gem install liquid_lint, github: 'zeusintuivo/liquid-lint'
```

## Usage

Run `liquid-lint` from the command line by passing in a directory (or multiple
directories) to recursively scan:

```bash
liquid-lint app/views/
```

You can also specify a list of files explicitly:

```bash
liquid-lint app/**/*.liquid
```

`liquid-lint` will output any problems with your Liquid, including the offending
filename and line number.

Command Line Flag         | Description
--------------------------|----------------------------------------------------
`-c`/`--config`           | Specify which configuration file to use
`-e`/`--exclude`          | Exclude one or more files from being linted
`-i`/`--include-linter`   | Specify which linters you specifically want to run
`-x`/`--exclude-linter`   | Specify which linters you _don't_ want to run
`--stdin-file-path [file]`| Pipe source from STDIN, using file in offense reports
`--[no-]color`            | Whether to output in color
`--reporter [reporter]`   | Specify which output formatter to use
`--show-linters`          | Show all registered linters
`--show-reporters`        | Show all available reporters
`-h`/`--help`             | Show command line flag documentation
`-v`/`--version`          | Show version
`-V`/`--verbose-version`  | Show detailed version information

## Configuration

`liquid-lint` will automatically recognize and load any file with the name
`.liquid-lint.yml` as a configuration file. It loads the configuration based on
the directory `liquid-lint` is being run from, ascending until a configuration
file is found. Any configuration loaded is automatically merged with the
default configuration (see [`config/default.yml`](config/default.yml)).

Here's an example configuration file:

```yaml
exclude:
  - 'exclude/files/in/this/directory/from/all/linters/**/*.liquid'

linters:
  EmptyControlStatement:
    exclude:
      - 'app/views/directory_of_files_to_exclude/**/*.liquid'
      - 'specific/file/to/exclude.liquid'

  LineLength:
    include: 'specific/directory/to/include/**/*.liquid'
    max: 100

  RedundantDiv:
    enabled: false
```

All linters have an `enabled` option which can be `true` or `false`, which
controls whether the linter is run, along with linter-specific options. The
defaults are defined in [`config/default.yml`](config/default.yml).

### Linter Options

Option        | Description
--------------|----------------------------------------------------------------
`enabled`     | If `false`, this linter will never be run. This takes precedence over any other option.
`include`     | List of files or glob patterns to scope this linter to. This narrows down any files specified via the command line.
`exclude`     | List of files or glob patterns to exclude from this linter. This excludes any files specified via the command line or already filtered via the `include` option.

### Global File Exclusion

The `exclude` global configuration option allows you to specify a list of files
or glob patterns to exclude from all linters. This is useful for ignoring
third-party code that you don't maintain or care to lint. You can specify a
single string or a list of strings for this option.

### Skipping Frontmatter

Some static blog generators such as [Jekyll](http://jekyllrb.com/) include
leading frontmatter to the template for their own tracking purposes.
`liquid-lint` allows you to ignore these headers by specifying the
`skip_frontmatter` option in your `.liquid-lint.yml` configuration:

```yaml
skip_frontmatter: true
```

### Disabling Linters For Specific Code

#### Liquid-lint linters

To disable a liquid-lint linter, you can use a liquid comment:
```liquid
/ liquid-lint:disable TagCase
IMG src="images/cat.gif"
/ liquid-lint:enable TagCase
```

### Rubocop cops
To disable Rubocop cop, you can use a coment control statement:
```liquid
- # rubocop:disable Rails/OutputSafety
p = raw(@blog.content)
- # rubocop:enable Rails/OutputSafety
```
## Linters

You can find detailed documentation on all supported linters by following the
link below:

### [» Linters Documentation](lib/liquid_lint/linter/README.md)

## Editor Integration

### Sublime Text

Install the
[Sublime liquid-lint plugin](https://sublime.wbond.net/packages/SublimeLinter-liquid-lint).

### Emacs

If you use Flycheck, support for `liquid-lint` is included as of version
20160718.215 installed from MELPA.

### Atom

Install the [`linter-liquid-lint`](https://github.com/mattaschmann/linter-liquid-lint)
plugin by running `apm install linter-liquid-lint`.

### Visual Studio Code

Install the
[VS Code liquid-lint plugin](https://marketplace.visualstudio.com/items?itemName=aliariff.liquid-lint).

## Git Integration

If you'd like to integrate `liquid-lint` into your Git workflow, check out
[overcommit](https://github.com/brigade/overcommit), a powerful and flexible
Git hook manager.

## Rake Integration

To execute `liquid-lint` via a [Rake](https://github.com/ruby/rake) task, make
sure you have `rake` included in your gem path (e.g. via `Gemfile`), and add
the following to your `Rakefile`:

```ruby
require 'liquid_lint/rake_task'

LiquidLint::RakeTask.new
```

By default, when you execute `rake liquid_lint`, the above configuration is
equivalent to running `liquid-lint .`, which will lint all `.liquid` files in the
current directory and its descendants.

You can customize your task by writing:

```ruby
require 'liquid_lint/rake_task'

LiquidLint::RakeTask.new do |t|
  t.config = 'custom/config.yml'
  t.files = ['app/views', 'custom/*.liquid']
  t.quiet = true # Don't display output from liquid-lint to STDOUT
end
```

You can also use this custom configuration with a set of files specified via
the command line:

```
# Single quotes prevent shell glob expansion
rake 'liquid_lint[app/views, custom/*.liquid]'
```

Files specified in this manner take precedence over the task's `files`
attribute.

## Documentation

[Code documentation] is generated with [YARD] and hosted by [RubyDoc.info].

[Code documentation]: http://rdoc.info/github/zeusintuivo/liquid-lint/master/frames
[YARD]: http://yardoc.org/
[RubyDoc.info]: http://rdoc.info/

## Contributing

We love getting feedback with or without pull requests. If you do add a new
feature, please add tests so that we can avoid breaking it in the future.

Speaking of tests, we use `rspec`, which can be run by executing the following
from the root directory of the repository:

```bash
bundle exec rspec
```

## Changelog

If you're interested in seeing the changes and bug fixes between each version
of `liquid-lint`, read the [Liquid-Lint Changelog](CHANGELOG.md).

## License

This project is released under the [MIT license](LICENSE.md).
