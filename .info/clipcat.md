# Clipcat

[github](https://github.com/xrelkd/clipcat.git)

## Build from source

`clipcat` requires the following tools and packages to build:

- `rustc`
- `cargo`
- `protobuf-compiler`

With the above tools and packages already installed, you can simply run:

```bash
git clone --branch=main https://github.com/xrelkd/clipcat.git
cd clipcat

cargo install --path clipcatd
cargo install --path clipcatctl
cargo install --path clipcat-menu
```
