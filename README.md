<p align="center">
  <img src=https://github.com/user-attachments/assets/22298671-aa0d-48c6-b7da-35c169f89636>
  <br/>
  <strong>Early-stage Hackable HCI tools</strong>
</p>

An AI-first, privacy respecting, integrated diagnostic and development suite built the Unix way, through small tools that can be orchestrated together.

 * **Tmux Talkers**: Rebranded as [sidechat](https://github.com/day50-dev/sidechat)
 * **[Shell Snoopers](#the-shell-snoopers)**: Tiny tools for shining up your shell
 * **[Xorg Xtractors](#the-xorg-xtractors)**: LLM interception and injection in your Xorg

## The Shell Snoopers 

**shell-hook, shellwrap and wtf**

### Shell-hook.zsh

Moved to [Zummoner](https://github.com/day50-dev/Zummoner).

### Shellwrap

Moved to [ESChatch](https://github.com/day50-dev/ESChatch).

### Tabchat

This is a fairly simple script you can just add to your `.{shell}sh`:
```bash
function tabchat() {
    bt html | markitdown | llm "Here is a document I'm going to ask you about" | sd
    llm chat -c | sd
}
```

This uses [brotab](https://github.com/balta2ar/brotab) to get the html from the  active tab (bt html) and then uses [markitdown](https://github.com/microsoft/markitdown) to convert it into ingestable markdown for an llm, then it uses [simonw's llm](https://github.com/simonw/llm) to add it to a context window and [streamdown](https://github.com/day50-dev/Streamdown) to format the markdowne.
![tabchat](https://github.com/user-attachments/assets/db5b1960-f0c3-4796-b9c5-fb5650fd859c)

### WTF
A tool designed to read a directory of files, describe their content, categorize their purposes and answer basic questions. Example!

(Notice how it has no idea what shellwrap does. Told you it was new! ;-) )

![un](https://github.com/user-attachments/assets/0fe52d11-cf79-45e1-ba3c-4bbbfba81610)

## The Xorg Xtractors

**kb-capture.py and llm-magic**

`kb-capture.py` captures keyboard events from an X server and converts them into a string.  It exits and prints the captured string when a semicolon (`;`) or colon (`:`) is pressed. `llm-magic` is a shell script that uses `kb-capture.py` to capture keyboard input, sends it to an LLM for processing, and displays the LLM's response using `dzen2` and then types it out using xdotool. 

Their powers combined gives you llm prompting in any application. Here the user is

 * ssh'ing to a remote machine
 * using a classic text editor (scite)
 * using classic vim

I do a keystroke to invoke `llm-magic`, type my request, then ; and it replaces my query with the response. Totally magic. Just like it says. 

![out](https://github.com/user-attachments/assets/07ed72d0-87ef-4270-b880-ae8797bd8c4e)


Thanks for stopping by!
