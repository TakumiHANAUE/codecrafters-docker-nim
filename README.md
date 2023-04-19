This is a starting point for Nim solutions to the
["Build Your Own Docker" Challenge](https://codecrafters.io/challenges/docker).

In this challenge, you'll build a program that can pull an image from
[Docker Hub](https://hub.docker.com/) and execute commands in it. Along the way,
we'll learn about [chroot](https://en.wikipedia.org/wiki/Chroot),
[kernel namespaces](https://en.wikipedia.org/wiki/Linux_namespaces), the
[docker registry API](https://docs.docker.com/registry/spec/api/) and much more.

**Note**: If you're viewing this repo on GitHub, head over to
[codecrafters.io](https://codecrafters.io) to try the challenge.

# Passing the first stage

The entry point for your Docker implementation is `app/main.nim`. Study and
uncomment the relevant code, and push your changes to pass the first stage:

```sh
git add .
git commit -m "pass 1st stage" # any msg
git push origin master
```

That's all!

# Stage 2 & beyond

Note: This section is for stages 2 and beyond.

You'll use linux-specific syscalls in this challenge. so we'll run your code
_inside_ a Docker container.

Please ensure you have [Docker installed](https://docs.docker.com/get-docker/)
locally.

Next, add a [shell alias](https://shapeshed.com/unix-alias/):

```sh
alias mydocker='docker build -t mydocker . && docker run --cap-add="SYS_ADMIN" mydocker'
```

(The `--cap-add="SYS_ADMIN"` flag is required to create
[PID Namespaces](https://man7.org/linux/man-pages/man7/pid_namespaces.7.html))

You can now execute your program like this:

```sh
mydocker run ubuntu:latest /usr/local/bin/docker-explorer echo hey
```

# Note

## 環境

`.devcontainer/devcontainer.json`参照

## 動作確認方法

- 実行後コンテナを消したいなら docker run オプションに `--rm` を追加
- STDOUT, STDERR を確認したいなら以下のいずれかの方法をとる。
  - Docker Desktop の ログを見る
  - VS Code の Docker 拡張から、コンテナを右クリックして View Logs
  - `$ docker logs mydocker_cont`

実行、エラーコード／標準出力を出力、コンテナ削除 を行う一連のコマンドは以下の通り。

```bash
$ docker build -t mydocker . && docker run --name mydocker_cont --cap-add="SYS_ADMIN" mydocker run [IMAGE] [COMMAND] [ARGS]...
$ echo "[Exit code] $?"
$ echo "[Logs]"
$ docker logs mydocker_cont
$ docker rm mydocker_cont
```

`exec_program.sh` としてスクリプト化した

## codecrafters test のローカル実施

### [CodeCrafters CLI をインストール](https://docs.codecrafters.io/cli/installation?_gl=1*atj0zz*_ga*MTk2NjkxNjg1LjE2NzMwMDEwNzk.*_ga_N8D6K4M2HE*MTY3NDk0NjA2Ni4yMS4wLjE2NzQ5NDYwNjYuMC4wLjA.)

```bash
$ curl https://codecrafters.io/install.sh | sh
```

### 実行方法

```bash
$ codecrafters test
```

