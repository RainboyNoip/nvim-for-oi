import subprocess
import sys
from typing import List, Optional, Any

class GumError(Exception):
    """Custom exception for gum-related errors."""
    pass

def _convert_kwargs_to_flags(kwargs: dict) -> List[str]:
    """Converts a dictionary of keyword arguments to a list of command-line flags."""
    flags = []
    for key, value in kwargs.items():
        flag = f"--{key.replace('_', '-')}"
        if isinstance(value, bool):
            if value:
                flags.append(flag)
        elif isinstance(value, list):
            for item in value:
                flags.extend([flag, str(item)])
        else:
            flags.extend([flag, str(value)])
    return flags

def _run_gum(subcommand: str, *args: str, **kwargs: Any) -> str:
    """
    A generic function to run a gum subcommand.
    Returns the standard output of the command.
    Raises GumError on failure.
    """
    try:
        command = ['gum', subcommand]
        command.extend(_convert_kwargs_to_flags(kwargs))
        command.extend(args)

        # By using stdout=subprocess.PIPE and letting stdin/stderr inherit from the parent,
        # we allow gum to render its interactive UI in the terminal while still
        # capturing the final selected output.
        process = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            text=True,
            check=False  # We check the return code manually
        )

        if process.returncode != 0:
            # `gum confirm` returning 1 means "No", which isn't a script-crashing error.
            # We let the `confirm` wrapper handle this specific case.
            # For other commands, a non-zero exit code is an error.
            if not (subcommand == 'confirm' and process.returncode == 1):
                 # An empty stderr often means the user cancelled (e.g., pressed Esc).
                if process.stderr:
                    raise GumError(f"gum {subcommand} exited with code {process.returncode}: {process.stderr.strip()}")
                # If no stderr, it's likely a cancellation, so we return an empty string.
        
        return process.stdout.strip()

    except FileNotFoundError:
        raise GumError("gum command not found. Is it installed and in your PATH? See: https://github.com/charmbracelet/gum")
    except Exception as e:
        raise GumError(str(e))

# --- Wrapper Functions ---

def input(**kwargs: Any) -> str:
    """Prompts the user for a line of text."""
    return _run_gum('input', **kwargs)

def write(**kwargs: Any) -> str:
    """Prompts the user for multi-line text."""
    return _run_gum('write', **kwargs)

def choose(options: List[str], **kwargs: Any) -> str:
    """Presents a list of options for the user to choose from."""
    # Pass options as command-line arguments for interactive UI
    return _run_gum('choose', *options, **kwargs)

def filter(options: List[str], **kwargs: Any) -> str:
    """Presents a filterable list of options."""
    # Pass options as command-line arguments for interactive UI
    return _run_gum('filter', *options, **kwargs)

def confirm(prompt: str = "Are you sure?", **kwargs: Any) -> bool:
    """Asks for a yes/no confirmation."""
    try:
        # We run the command but don't need its output, only the exit code.
        # The return code logic is handled inside _run_gum.
        # This will now correctly show the interactive prompt.
        _run_gum('confirm', prompt, **kwargs)
        return True # If _run_gum didn't raise an error, it means return code was 0 ("Yes").
    except GumError as e:
        # A non-zero return code from confirm will raise a GumError.
        # We catch it and interpret it as "No".
        return False

def spin(command: List[str], title: str = "Running...", **kwargs: Any) -> str:
    """Displays a spinner while a command runs."""
    kwargs['title'] = title
    return _run_gum('spin', '--', *command, **kwargs)

def style(text: str, **kwargs: Any) -> str:
    """Applies styling to a string."""
    return _run_gum('style', text, **kwargs)

def join(parts: List[str], **kwargs: Any) -> str:
    """Joins text horizontally or vertically."""
    return _run_gum('join', *parts, **kwargs)

# --- Example Usage ---
if __name__ == '__main__':
    try:
        print("--- gum.input ---")
        name = input(placeholder="What's your name?")
        print(f"Hello, {name}!" if name else "No name entered.")

        print("\n--- gum.confirm ---")
        if confirm("Do you like bubble tea?"):
            print("Great taste! 🧉")
        else:
            print("You're missing out!")

        print("\n--- gum.choose ---")
        drink = choose(["Coffee", "Tea", "Water", "Juice"], header="Choose a drink:")
        if drink:
            print(f"You chose: {drink}")
        else:
            print("You cancelled the selection.")

        print("\n--- gum.filter ---")
        food = filter(["Pizza", "Burger", "Salad", "Sushi", "Pasta"], placeholder="Find a food...")
        if food:
            print(f"You filtered and chose: {food}")
        else:
            print("You cancelled the selection.")

        print("\n--- gum.style ---")
        styled_text = style(
            "This is styled text.",
            foreground="212",
            border="double",
            padding="1 2",
            margin="1"
        )
        print(styled_text)
        
        print("\n--- gum.join ---")
        part1 = style("Hello", foreground="212", padding="1")
        part2 = style("World", foreground="22", padding="1")
        joined_text = join([part1, part2], horizontal=True)
        print(joined_text)

        print("\n--- gum.spin ---")
        print("Running 'sleep 2' with a spinner...")
        # Note: 'spin' will capture the output of the command it runs.
        output = spin(['sleep', '2'], title="Sleeping for 2 seconds...")
        print("Spinner finished.")
        if output:
            print(f"Command output: {output}")

    except GumError as e:
        print(f"An error occurred: {e}", file=sys.stderr)
        sys.exit(1)