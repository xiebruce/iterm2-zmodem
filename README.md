# iTerm2-zmodem scripts

[中文文档](https://www.xiebruce.top/1863.html)
[详细文档](https://www.xiebruce.top/1863.html)

These two shells are work with iTerm2 and rz/sz to allow it upload files to server.

## Config steps

- 1.Install `lrzsz` on your server

  ```
  # Debian
  apt install lrzsz

  # redhat/centos7
  yum install lrzsz

  # centos8
  dnf install lrzsz
  ```

- 2.Install `lrzsz` on your macOS

  ```
  brew install lrzsz
  ```

- 3.Download these two scripts to `/usr/local/bin/`

  ```bash
  wget https://raw.githubusercontent.com/xiebruce/iterm2-zmodem/main/iterm2-rz.sh -O /usr/local/bin/iterm2-rz.sh

  wget https://raw.githubusercontent.com/xiebruce/iterm2-zmodem/main/iterm2-sz.sh -O /usr/local/bin/iterm2-sz.sh
  ```

- 4.Give executable permission to these two files

  ```bash
  chmod u+x /usr/local/bin/iterm2-*
  ```

- 5.Add triggers: iTerm2→Preferences→Profiles→Default(or other profile)→Advanced→Triggers→Edit, add two triggers as the screenshot
  ![iTerm2-add-triggers1](./img/iTerm2-add-triggers1.jpg)
  ![iTerm2-add-triggers2](./img/iTerm2-add-triggers2.jpg)

  | Regular Expression                | Action                  | Parameters                  | Instant | Enabled |
  | --------------------------------- | ----------------------- | --------------------------- | :------ | :------ |
  | \\*\\*B00                         | Run Silent Coprocess... | /usr/local/bin/iterm2-rz.sh | check   | check   |
  | rz waiting to receive.\\*\\*B0100 | Run Silent Coprocess... | /usr/local/bin/iterm2-sz.sh | check   | check   |

  Note that if you add other profile to login to your server, you should add triggers on that profile, every profile keep their own triggers.
  ![iTerm2-add-triggers1](./img/iTerm2-add-triggers3.jpg)

- 6.Enable drag&drop upload: iTerm2→Preferences→Advanced→search "dropp"
  ![iTerm2-add-triggers1](./img/iTerm2-drag&drop-trigger.jpg)
  input the following command

  ```bash
  /usr/local/bin/iterm2-sz.sh dragfiles \(filenames)
  ```

## Usage

Fist login to your server

```bash
ssh user@12.34.56.78
```

**Upload files**:

- Method 1: on server, type `rz`, press Enter, wait for a while, choose files you want to upload.
- Method 2: on server, drag a file/folder and drop it to the iTerm2 window(note that you can only drag&drop one file/folder, and you need to update iTerm2 to [iTerm2-3_5_20230503-nightly.zip](https://iterm2.com/downloads/nightly/iTerm2-3_5_20230503-nightly.zip) or higher).

**Download files**: on server, type `sz /path/to/file`, press Enter, wait for a while, the file will be downloaded to your macOS "Downloads" folder.

```bash
# send multi files to you macOS(you can think of it as download file from server)
sz /path/to/file1 /path/to/file2 "/path/to/file name have space"

# send all files under the folder to your macOS
sz /path/to/folder/*
```

If you want to choose which folder you want to save to, you can add the following environment variable to `~/.bashrc`

```bash
export CHOOSE_FOLDER=true
```

Note that no matter you are using zsh or fish or other shell, you should add it to `~/.bashrc`, otherwise it will not work.

For more details, see [here](https://www.xiebruce.top/1863.html).
