# Toolbox
[![build](https://github.com/vstelmakh/toolbox/actions/workflows/build.yml/badge.svg)](https://github.com/vstelmakh/toolbox/actions)

**Toolbox** - is a collection of tools to make my life (work) easier. It contains various bash scripts to simplify common tasks.
Generally it's a wrapper on other tools to make usage more convenient, and with autocompletion.

<details>
    <summary>🧰 Available commands</summary>

```text
   __              ____
  / /_____  ____  / / /_  ____  _  __
 / __/ __ \/ __ \/ / __ \/ __ \| |/_/
/ /_/ /_/ / /_/ / / /_/ / /_/ />  <
\__/\____/\____/_/_.___/\____/_/|_|

Available commands:
  audio        Switch system audio output
  aws          Run AWS CLI command in Docker container
  base64       Decode or encode base64 input
  branch       Convert ticket title to Git branch name
  gif          Convert input video to gif
  ip           Detect and print current public IP
  password     Generate random password
  url          Decode or encode url input
  self-config  Validate config file
  self-lint    Lint toolbox project shell scripts
  self-setup   Setup toolbox executable and command autocompletion for current user
  self-test    Run toolbox project tests
  self-update  Update toolbox to the latest version
```
</details>

> 💡
> After setup, run `toolbox` to see available commands. Each command has `--help` option to show usage examples.

## Setup
1. Clone the repository into desired location
2. Execute `./bin/toolbox self-setup`
3. Create `config.env` from `config.env.dist` and adjust the parameters
4. Re-login current user
5. Use the tools available under `toolbox` command

> 💡
> Generally toolbox is ready to be used directly after clone, by executing `./bin/toolbox`.
> But without `self-setup` autocomplete won't work.
> And commands that require `config.env` won't work as well.

## Requirements
Toolbox is developed and tested on Ubuntu with an idea to work out of the box.
But some commands may require some extra dependencies like git or docker etc.
Compatibility with other systems is unknown.

## Contribution
If you see something to improve, fix or add - you are welcome to submit a PR.
But keep in mind that this project is mostly for my personal use, so I may not accept your changes if they don't fit my preferences.
Also, you can always fork the project and make your own toolbox.

## Credits
[Volodymyr Stelmakh](https://github.com/vstelmakh)  
Licensed under the MIT License. See [LICENSE](LICENSE) for more information. 
