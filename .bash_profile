export PATH="$HOME/bin:$PATH"

for file in ~/.{profile,path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && source "$file"
done
