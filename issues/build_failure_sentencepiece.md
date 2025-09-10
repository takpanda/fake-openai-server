## Issue: Build Failure Due to SentencePiece Library API Changes

### Description
The build is currently failing due to changes in the SentencePiece library API. The specific error messages indicate that the following symbols are missing:
- `SentencePieceNormalizer`
- Related symbols

This issue arises from using an incompatible version of the SentencePiece library. 

### Recommendation
To resolve this issue, we recommend pinning the SentencePiece library version to **0.1.99** or another compatible version. This can be done by updating the following files:
- `requirements.txt`
- `pyproject.toml`
- `Dockerfile`

### Error Logs
```
# [Include relevant error log snippets here]
```

Please address this issue at the earliest to ensure that the build process is restored.