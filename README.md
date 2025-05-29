<p align="center">
  <H3>LLM Incubator</H3>
  <br/>
  <strong>Hackable HCI tools to fix all those AI bugs</strong>
</p>

An AI-first, privacy respecting, integrated diagnostic and development suite built the Unix way, through small tools that can be orchestrated together.

 * **[Tmux Talkers](#the-tmux-talkers)**: Rebranded as [sidechat](https://github.com/day50-dev/sidechat)
 * **[Shell Snoopers](#the-shell-snoopers)**: Tiny tools for shining up your shell
 * **[Xorg Xtractors](#the-xorg-xtractors)**: LLM interception and injection in your Xorg

## The Shell Snoopers 

**shell-hook, shellwrap and wtf**

### Shell-hook.zsh

Moved to [Zummoner](https://github.com/day50-dev/Zummoner).

### Shellwrap

Moved to [ESChatch](https://github.com/day50-dev/ESChatch).

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
