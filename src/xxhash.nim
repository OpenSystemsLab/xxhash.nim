import pkg/nint128

{.compile: "private/xxHash/xxhash.c".}

# One-shot functions
proc XXH32*(input: ptr UncheckedArray[byte], length: csize_t, seed: uint32): uint32 {.cdecl, importc.}
proc XXH64*(input: ptr UncheckedArray[byte], length: csize_t, seed: uint64): uint64  {.cdecl, importc.}

proc XXH32*(input: cstring, length: int, seed: uint32): uint32 {.inline.} =
  XXH32(cast[ptr UncheckedArray[byte]](input), length.csize_t, seed)

proc XXH64*(input: cstring, length: int, seed: uint64): uint64 {.inline.} =
  XXH64(cast[ptr UncheckedArray[byte]](input), length.csize_t, seed)

proc XXH32*(input: string, seed = 0): uint32 {.inline.} =
  XXH32(input.cstring, input.len, seed.uint32)

proc XXH64*(input: string, seed = 0): uint64 {.inline.} =
  XXH64(input.cstring, input.len, seed.uint64)

proc XXH3_64bits*(input: ptr UncheckedArray[byte], length: csize_t): uint64 {.cdecl, importc.}
proc XXH3_64bits_withSeed*(input: ptr UncheckedArray[byte], length: csize_t, seed: uint64): uint64 {.cdecl, importc.}

template XXH3_64bits*(input: string): uint64 =
  XXH3_64bits(cast[ptr UncheckedArray[byte]](input.cstring), input.len.csize_t)
template XXH3_64bits_withSeed*(input: string, seed: uint64): uint64 =
  XXH3_64bits_withSeed(cast[ptr UncheckedArray[byte]](input.cstring), input.len.csize_t, seed)


proc XXH3_128bits*(input: ptr UncheckedArray[byte], length: csize_t): UInt128 {.cdecl, importc.}
proc XXH3_128bits_withSeed*(input: ptr UncheckedArray[byte], length: csize_t, seed: uint64): UInt128 {.cdecl, importc.}
proc XXH3_128bits_withSecret*(input: ptr UncheckedArray[byte], length: csize_t, secret: ptr UncheckedArray[byte], secretSize: csize_t): UInt128 {.cdecl, importc.}
proc XXH3_128bits_withSecretandSeed*(input: ptr UncheckedArray[byte], length: csize_t, secret: ptr UncheckedArray[byte], secretSize: csize_t, seed: uint64): UInt128 {.cdecl, importc.}

template XXH3_128bits*(input: string): UInt128 =
  XXH3_128bits(cast[ptr UncheckedArray[byte]](input.cstring), input.len.csize_t)
template XXH3_128bits_withSeed*(input: string, seed: uint64): UInt128 =
  XXH3_128bits_withSeed(cast[ptr UncheckedArray[byte]](input.cstring), input.len.csize_t, seed)
template XXH3_128bits_withSecret*(input: string, secret: string): UInt128 =
  XXH3_128bits_withSecret(cast[ptr UncheckedArray[byte]](input.cstring), input.len.csize_t, cast[ptr UncheckedArray[byte]](secret.cstring), secret.len.csize_t)
template XXH3_128bits_withSecretandSeed*(input: string, secret: string, seed: uint64): UInt128 =
  XXH3_128bits_withSecretandSeed(cast[ptr UncheckedArray[byte]](input.cstring), input.len.csize_t, cast[ptr UncheckedArray[byte]](secret.cstring), secret.len.csize_t, seed)

# Streaming api
type
  LLxxh64State* = pointer
  LLxxh32State* = pointer
  LLxxh3_64State* = pointer
  Xxh32State* = object
    llstate*: LLxxh32State # wrapped in a object for destructor
  Xxh64State* = object
    llstate*: LLxxh64State # wrapped in a object for destructor
  Xxh3_64State* = object
    llstate*: LLxxh3_64State # wrapped in a object for destructor
  Xxh128State* = object
    llstate*: LLxxh3_64State

proc XXH32_createState*(): LLxxh32State {.cdecl, importc: "XXH32_createState".}
proc XXH32_freeState*(state: LLxxh32State) {.cdecl, importc: "XXH32_freeState".}
proc XXH32_reset*(state: LLxxh32State, seed: uint32 = 0) {.cdecl, importc: "XXH32_reset".}
proc XXH32_update*(state: LLxxh32State, input: cstring, len: int) {.cdecl, importc: "XXH32_update".}
proc XXH32_digest*(state: LLxxh32State): uint32 {.cdecl, importc: "XXH32_digest".}

proc newXxh32*(seed: uint32 = 0): Xxh32State =
  result.llstate = XXH32_createState()
  result.llstate.XXH32_reset(seed)

proc update*(state: Xxh32State, input: string) =
  state.llstate.XXH32_update(input.cstring, input.len)

proc digest*(state: Xxh32State): uint32 =
  return state.llstate.XXH32_digest()

proc `$`*(state: Xxh32State): string =
  return $state.digest

proc reset*(state: Xxh32State, seed = 0'u32) =
  state.llstate.XXH32_reset(seed)

proc `=destroy`*(state: Xxh32State) =
  state.llstate.XXH32_freeState()


proc XXH3_createState*(): LLxxh3_64State {.cdecl, importc: "XXH3_createState".}
proc XXH3_freeState*(state: LLxxh3_64State) {.cdecl, importc: "XXH3_freeState".}
proc XXH3_64_reset*(state: LLxxh3_64State) {.cdecl, importc: "XXH3_64bits_reset".}
proc XXH3_64_reset_withSeed*(state: LLxxh3_64State, seed: uint64 = 0) {.cdecl, importc: "XXH3_64bits_reset_withSeed".}
proc XXH3_64_update*(state: LLxxh3_64State, input: cstring, len: int) {.cdecl, importc: "XXH3_64bits_update".}
proc XXH3_64_digest*(state: LLxxh3_64State): uint64 {.cdecl, importc: "XXH3_64bits_digest".}

proc newXxH3_64*(seed: uint64 = 0): XxH3_64State =
  result.llstate = XXH3_createState()
  result.llstate.XXH3_64_reset_withSeed(seed)

proc update*(state: XxH3_64State, input: string) =
  state.llstate.XXH3_64_update(input.cstring, input.len)

proc digest*(state: XxH3_64State): uint64 =
  return state.llstate.XXH3_64_digest()

proc `$`*(state: XxH3_64State): string =
  return $state.digest

proc reset*(state: XxH3_64State, seed = 0'u64) =
  state.llstate.XXH3_64_reset_withSeed(seed)

proc `=destroy`*(state: XxH3_64State) =
  state.llstate.XXH3_freeState()

proc XXH64_createState*(): LLxxh64State {.cdecl, importc: "XXH64_createState".}
proc XXH64_freeState*(state: LLxxh64State) {.cdecl, importc: "XXH64_freeState".}
proc XXH64_reset*(state: LLxxh64State, seed: uint64 = 0) {.cdecl, importc: "XXH64_reset".}
proc XXH64_update*(state: LLxxh64State, input: cstring, len: int) {.cdecl, importc: "XXH64_update".}
proc XXH64_digest*(state: LLxxh64State): uint64 {.cdecl, importc: "XXH64_digest".}

proc newXxh64*(seed: uint64 = 0): Xxh64State =
  result.llstate = XXH64_createState()
  result.llstate.XXH64_reset(seed)

proc update*(state: Xxh64State, input: string) =
  state.llstate.XXH64_update(input.cstring, input.len)

proc digest*(state: Xxh64State): uint64 =
  return state.llstate.XXH64_digest()

proc `$`*(state: Xxh64State): string =
  return $state.digest

proc reset*(state: Xxh64State, seed = 0'u64) =
  state.llstate.XXH64_reset(seed)

proc `=destroy`*(state: Xxh64State) =
  state.llstate.XXH64_freeState()

proc XXH128_reset*(state: LLxxh3_64State, seed: uint64 = 0) {.cdecl, importc: "XXH3_128bits_reset".}
proc XXH128_reset_withSeed*(state: LLxxh3_64State, seed: uint64 = 0) {.cdecl, importc: "XXH128_reset_withSeed".}
proc XXH128_reset_withSecret*(state: LLxxh3_64State, secret: cstring, len: int) {.cdecl, importc: "XXH128_reset_withSecret".}
proc XXH128_update*(state: LLxxh3_64State, input: cstring, len: int) {.cdecl, importc: "XXH128_update".}
proc XXH128_digest*(state: LLxxh3_64State): UInt128 {.cdecl, importc: "XXH128_digest".}

proc newXxh128*(seed: uint64 = 0): Xxh128State =
  result.llstate = XXH3_createState()
  result.llstate.XXH128_reset_withSeed(seed)

proc newXxh128*(secret: string): Xxh128State =
  result.llstate = XXH3_createState()
  result.llstate.XXH128_reset_withSecret(secret.cstring, secret.len)

proc update*(state: Xxh128State, input: string) =
  state.llstate.XXH128_update(input.cstring, input.len)

proc digest*(state: Xxh128State): UInt128 =
  return state.llstate.XXH128_digest()

proc `$`*(state: Xxh128State): string =
  return $state.digest

proc reset*(state: Xxh128State, seed = 0'u64) =
  state.llstate.XXH128_reset_withSeed(seed)

proc resetWithSecret*(state: Xxh128State, secret: string) =
  state.llstate.XXH128_reset_withSecret(secret.cstring, secret.len)

proc `=destroy`*(state: Xxh128State) =
  state.llstate.XXH3_freeState()

when isMainModule:
  import strutils
  block:
    # One Shot
    assert 3794352943'u32 == XXH32("Nobody inspects the spammish repetition")
    assert 0xB559B98D844E0635'u64 == XXH64("xxhash", 20141025)

  block:
    assert 16629034431890738719'u64 == XXH3_64bits("a")
    assert 0x7051CC31E84FF73'u64 == XXH3_64bits("meow")
    assert 0x4268DCFE699316D8'u64 == XXH3_64bits_withSeed("meow meow meow", 42)
    assert XXH3_64bits("Abracadabra") == XXH3_64bits_withSeed("Abracadabra", 0)

  block:
    assert parseUInt128("225219434562328483135862406050043285023") == XXH3_128bits("a")
    assert parseUInt128("225219434562328483135862406050043285023") == XXH3_128bits_withSeed("a", 0)
    assert parseUInt128("337425133163118381928709500770786453280") == XXH3_128bits_withSeed("a", 1)

  const msg = "foo"
  const msgh32 = 0xe20f0dd9'u32
  const msgh64 = 0x33bf00a859c4ba3f'u64
  block:
    # LowLevel Streaming 64bit
    let state64 = XXH64_createState()
    state64.XXH64_reset()
    state64.XXH64_update(msg.cstring, msg.len)
    assert state64.XXH64_digest() == XXH64(msg)
    assert state64.XXH64_digest() == msgh64
    XXH64_freeState(state64)

  block:
    # LowLevel Streaming 32bit
    let state32 = XXH32_createState()
    state32.XXH32_reset()
    state32.XXH32_update(msg.cstring, msg.len)
    assert state32.XXH32_digest() == XXH32(msg)
    assert state32.XXH32_digest() == msgh32
    XXH32_freeState(state32)

  block:
    # HighLevel Streaming 32bit
    var state = newXxh32()
    state.update(msg)
    assert state.digest() == msgh32
    assert $state == $msgh32

    state.reset()
    state.update("Nobody ")
    state.update("inspects ")
    state.update("the spammish ")
    state.update("repetition")
    assert state.digest() == 3794352943'u32
    assert $state == $3794352943'u32
    state.reset()

  block:
    # HighLevel Streaming 64bit
    var state = newXxh64()
    state.update(msg)
    assert state.digest() == msgh64
    assert $state == $msgh64
    state.reset()
