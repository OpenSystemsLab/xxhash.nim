{.compile: "private/xxHash/xxhash.c".}


proc XXH32*(input: cstring, length: int, seed: uint32): uint32 {.cdecl, importc: "XXH32".}
proc XXH64*(input: cstring, length: int, seed: uint64): uint64  {.cdecl, importc: "XXH64".}


proc XXH32*(input: string, seed = 0): uint32 {.inline.} =
  XXH32(input.cstring, input.len, seed.uint32)

proc XXH64*(input: string, seed = 0): uint64 {.inline.} =
  XXH64(input.cstring, input.len, seed.uint64)

when isMainModule:
  assert 3794352943.uint32 == XXH32("Nobody inspects the spammish repetition")
  assert 0xB559B98D844E0635.uint64 == XXH64("xxhash", 20141025)
