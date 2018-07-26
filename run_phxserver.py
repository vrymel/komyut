#!/usr/bin/python
import subprocess

def get_flags():
    flags = []
    with open('.env') as f:
        for line in f:
            line = line.strip()
            # Ignore comments
            if not line.startswith('#'):
                flags.append(line)

    return ' '.join(flags)

flags = get_flags()
change_dir = 'cd app'
mix_command = 'mix phx.server'
main_command = '{} {}'.format(flags, mix_command)

final_command = '{} && {}'.format(change_dir, main_command)

print("Running mix phx.server")
subprocess.call(final_command, shell=True)
