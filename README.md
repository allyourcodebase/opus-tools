# opus-tools
Zig build for xiph/opus-tools

## NOTE
This package currently only covers `speex_resampler.h`. PRs welcome if more 
coverage of the upstream project is needed.

To use the library correctly you have to define two macros:

```zig
const c = @cImport({
    @cDefine("OUTSIDE_SPEEX", "1");
    @cDefine("RANDOM_PREFIX", "speex");
    @cInclude("speex_resampler.h");
});
```
