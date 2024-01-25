# Toolbox
[![build](https://github.com/vstelmakh/toolbox/actions/workflows/build.yml/badge.svg)](https://github.com/vstelmakh/toolbox/actions)

**Toolbox** - is a collection of tools to make my life (work) easier. It contains various bash scripts to simplify common tasks.

## Setup
1. Clone the repository into desired location
2. Execute `./bin/toolbox self-setup`
3. Create `config.env` from `config.env.dist` and adjust the parameters
4. Re-login current user
5. Use the tools available under `toolbox` command

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
