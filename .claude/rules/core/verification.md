# Verification Before Completion

## Iron Law

If you did not run the verification command in this message, you cannot claim it passed.

## Gate Function

Required before declaring completion:

1. IDENTIFY — Which command proves this claim?
2. RUN — Execute that command (fresh, complete)
3. READ — Read full output, check exit code
4. VERIFY — Does output support the claim?
5. CLAIM — Only then declare the result

## Prohibited Phrases

- "It should work", "No issues expected", "Already verified" (prior runs are not evidence)

## Required Evidence

| Claim        | Required Evidence       | Insufficient Evidence                |
| ------------ | ----------------------- | ------------------------------------ |
| Tests pass   | Test execution output   | Prior run, "it will pass"            |
| Build succeeds | Build command exit 0  | "Lint passed so build will too"      |
| Bug fixed    | Regression test passes  | "Code changed so it's fixed"         |
