#!/usr/bin/python
import subprocess
import argparse

def get_flags():
    flags = []
    with open('.env') as f:
        for line in f:
            line = line.strip()
            # Ignore comments
            if not line.startswith('#'):
                flags.append(line)

    return ' '.join(flags)


parser = argparse.ArgumentParser()
parser.add_argument('--detached', action='store_true', help='Run server in detached mode')
args = parser.parse_args()

flags = get_flags()
change_dir = 'cd app'
mix_command = 'mix phx.server'
if args.detached:
    print('Using detached mode')
    mix_command = 'elixir --detached -S mix do compile, phx.server'

main_command = '{} {}'.format(flags, mix_command)
final_command = '{} && {}'.format(change_dir, main_command)

print('Running mix phx.server')
subprocess.call(final_command, shell=True)
