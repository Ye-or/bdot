# skim

[github](https://github.com/skim-rs/skim.git)

## Build from source

- Using Binary: Simply [download the sk executable](https://github.com/skim-rs/skim/releases) directly.
- Install from [crates.io](https://crates.io/): `cargo install skim`
- Build Manually:

    ```sh
    git clone --depth 1 git@github.com:skim-rs/skim.git ~/.skim
    cd ~/.skim
    cargo build --release
    # Add the resulting `target/release/sk` executable to your PATH
    ```

You will then have access to:

- The man page, which you can either write to the correct path or run `man --local-file <(sk --man)`
- The shell completions (and optional keybinds), using `source <(sk --shell \<shell> \[--shell-bindings])`, see below for details
