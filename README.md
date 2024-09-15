# charfudge
Generate junk characters with randomized encoding. For use with fuzzing tools.

The tool starts off with a broad range of single and multibyte characters, and applies a base transformation and a set of randomized encodings.

**Note:** Some raw control characters can potentially mess up your terminal if the output is printed instead of piped.

## Usage
```
charfudge <number of lines to generate>
```

Try piping output into tools like [ffuf](https://github.com/ffuf/ffuf), [Gobuster](https://github.com/OJ/gobuster), [COOK](https://github.com/glitchedgitz/cook), etc.

## Example output
```
$ charfudge 10
%5C%5Cu00001087
%5Cu000030F5
💀
%255Cu307E
\u{0000000F}
%5C%5C%5C%5Cu0000FF64
\\\\u0000FFC5
ဏ 
\u{000000DD}
\x44
```

## Transformations
* Raw output (no transformation)
* Hex escaped (`\xNN`)
* Unicode escaped (Shell, JavaScript, others; `\uNNNN`, `\UNNNNNNNN`, `\uNNNNNNNN`, `\u{NNNN}`, `\u{NNNNNNNN}`)

## Encoding methods
* URL encoding (`%NN`)
* JavaScript string escaping (backslash)
* Shell string escaping (backslash, `$'...'`)
