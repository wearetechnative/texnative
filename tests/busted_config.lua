-- Busted configuration for texnative unit tests
return {
  default = {
    ROOT = {"tests/unit/"},
    pattern = "_spec",
    lpath = "./?/init.lua;./tests/?.lua;./tests/mocks/?.lua;./_extensions/texnative/?.lua",
    output = "utfTerminal",
    verbose = true
  }
}
