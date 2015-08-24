{.compile: "private/xxhash.c".}


proc XXH32*(input: cstring, length: csize, seed: cuint): cuint {.cdecl, importc: "XXH32", header: "../private/xxhash.h".}
proc XXH64*(input: cstring, length: csize, seed: culonglong): culonglong  {.cdecl, importc: "XXH32", header: "../private/xxhash.h".}


proc XXH32*(input: string, seed: cuint): uint32 {.inline.} =
  XXH32(input.cstring, input.len, seed)

proc XXH64*(input: string, seed: cuint): uint64{.inline.} =
  XXH32(input.cstring, input.len, seed)

proc XXH32*(input: string): uint32 {.inline.} =
  XXH32(input.cstring, input.len, 0)

proc XXH64*(input: string): uint64 {.inline.} =
  XXH32(input.cstring, input.len, 0)


when isMainModule:
  assert 3794352943.uint32 == XXH32("Nobody inspects the spammish repetition")
  assert 1740325085.uint64 == XXH64("xxhash", 20141025)
  echo 1740325085.uint64
