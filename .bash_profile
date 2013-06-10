export PATH="$HOME/bin:$PATH"

for file in ~/.{path,bash_prompt,exports,aliases,functions,extra,bash_completion}; do
	[ -r "$file" ] && source "$file"
done
