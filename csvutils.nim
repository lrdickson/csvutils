import std/math
import std/os
import std/parseopt
import std/tables
import std/sets

import datamancer

proc sum(df: DataFrame, column: string): float =
  var res = df.summarize(f{float: "sum" << sum(col(column))})
  round(res["sum", 0].tofloat(), 13)

proc sum(df: DataFrame, column: int): float =
  var column = df.getKeys[column]
  var res = df.summarize(f{float: "sum" << sum(col(column))})
  round(res["sum", 0].tofloat(), 13)

var options = [
    ("sum", ["s", "sum"])
    ]
var optionsMap: Table[string, string]
for (name, args) in options:
  for arg in args:
    optionsMap[arg] = name

var flags = [
    ("no-header", ["H", "no-header"])
    ]
var flagsMap: Table[string, string]
for (name, args) in flags:
  for arg in args:
    flagsMap[arg] = name

proc main() =
  var passedOptions: seq[(string, string)]
  var passedFlags = initHashSet[string]()
  var evalOption = ""
  var csv = ""
  for kind, key, val in commandLineParams().getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      if flagsMap.contains(key):
        passedFlags.incl(flagsMap[key])
        continue
      if val == "":
        evalOption = key
      else:
        passedOptions.add((optionsMap[key], val))
    of cmdArgument:
      if evalOption == "":
        csv = key
      else:
        passedOptions.add((optionsMap[evalOption], key))
      evalOption = ""
    of cmdEnd:
      discard

  var header = not passedFlags.contains("no-header")
  var df = readCsv(csv)
  if passedOptions.len == 0:
    echo df
    quit(QuitSuccess)
  for (key, val) in passedOptions:
    case key
    of "sum":
      echo df.sum(val)

when isMainModule:
  main()
