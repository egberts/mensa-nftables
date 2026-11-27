#!/usr/bin/env python3

import os
import re
import sys
from nftables import Nftables


def has_net_admin():
    with open("/proc/self/status") as status:
        for line in status:
            if line.startswith("CapEff:"):
                effective = int(line.split()[1], 16)
                return bool(effective & (1 << 12))
    return False


def main():

    # Require root privileges.
    if os.geteuid() != 0:

        # Non-root?  Check for CAP_NET_ADMIN capability privilege
        if not has_net_admin():
            # has
            print("ERROR: This script requires root privileges.")
            print("ERROR: or CAP_NET_ADMIN capability is required.")
            print(f"Interpreter: {sys.executable}")
            print("Grant it with:")
            print(f"  sudo setcap cap_net_admin+ep {sys.executable}")
            print(f"or")
            print(f"Execute with:\n  sudo {sys.executable} {os.path.abspath(__file__)}")
            sys.exit(1)

    nft = Nftables()

    # Enumerate existing tables.
    rc, output, error = nft.cmd("list tables")

    if rc:
        sys.exit(f"ERROR: Unable to enumerate tables: {error}")

    tables = []

    for line in output.splitlines():
        match = re.fullmatch(r"\s*table\s+(\S+)\s+(\S+)\s*", line)
        if match:
            tables.append(match.groups())

    if not tables:
        print("No nftables tables found.")
        return

    # Display all tables before requesting confirmation.
    print(f"\nFound {len(tables)} nftables tables:\n")

    for family, name in tables:
        print(f"  {family:<10} {name}")

    # Confirm before making changes.
    answer = input("\nContinue? [y/N]: ").strip().lower()

    if answer not in ("y", "yes"):
        print("Aborted.")
        return

    print("\nBeginning table flush operations:\n")

    # Flush each table individually.
    failures = 0

    for family, name in tables:
        command = f"flush table {family} {name}"

        print(f"{family} {name}  <--  {command}", flush=True)

        rc, output, error = nft.cmd(command)

        if rc:
            failures += 1
            print(f"  FAILED: {error}")
        else:
            print("  OK")

    print(f"\nCompleted: {len(tables) - failures} successful, "
          f"{failures} failed.")


if __name__ == "__main__":
    main()
