# AlphaWord – Clean Starter (XcodeGen + Codemagic)

## Build locally
```bash
brew install xcodegen
xcodegen --spec project.yml generate
open AlphaWord.xcodeproj
# or build via CLI:
xcodebuild -project AlphaWord.xcodeproj -scheme AlphaWord -configuration Debug build
```

## CI (Codemagic)
Push this repo and add it to Codemagic. The provided `codemagic.yaml` builds without code signing.