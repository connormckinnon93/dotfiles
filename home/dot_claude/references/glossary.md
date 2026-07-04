# GLOSSARY

Capitalized keywords carry the meanings defined in this document. Lowercase uses of the same words are ordinary English and carry no special directive force.

Keywords that are separated by `/` are synonyms. They carry nearly identical meaning.

## REQUIREMENTS

| Keyword | Meaning | Notes |
| --- | --- | --- |
| `MUST` / `REQUIRED` / `ALWAYS` | Hard requirement. No discretion. Violation is a failure. | Should only be used rarely so as not to dilute importance. |
| `MUST NOT` / `NEVER` | Hard prohibition. Violation is a failure. | SHOULD be paired with positive alternative (e.g. `NEVER` X `INSTEAD, DO` Y). |
| `SHOULD` / `PREFER` / `DEFAULT TO` | Strong default. Deviate only when needed. |   |
| `SHOULD NOT` / `AVOID` | Discouraged. Deviate only when needed. |   |

## PERMISSIONS vs CAPABILITY

| Keyword | Meaning | Notes |
| --- | --- | --- |
| `MAY` | Permission -- the agent is _allowed_ to. Options are equally preferable. | Granting latitude (e.g. "You `MAY` X `WHEN` Y" or "You `MAY` X `WHEN` A, B, `OR` C. |
| `CAN` | Capability -- it is _possible_ for the agent to. | Stating possibility (e.g. "You `CAN` X `WHEN` Y" or "You `CAN` X to Y") |

## CONDITIONS & VALIDATION

| Keyword | Meaning | Notes |
| --- | --- | --- |
| `WHEN` / `IF` `<condition>` ... [`ELSE` / `OTHERWISE`] ...  [`THEN` `<action>`] | Apply the rule when condition holds. With possible branching logic and specific actions prescribed. |   |
| `UNLESS` / `WITHOUT` `<condition>` | Default applies except in the named case. |   |
| `ONCE` `<condition>` | Triggered when specified condition is true. |   |
| `UNTIL` `<condition>` | Triggered while specified condition is not true. |   |
| `WHILE` `<condition>` | Triggered while specified condition is true. | Antonym of `UNTIL`. |
| `ENSURE` `<condition>` | Define ideal condition | Antonym is `PREVENT` |
| `CHECK` / `CONFIRM` / `VERIFY` / `VALIDATE` `<state>` [`AGAINST` `<criterion>`] | Validate state against a standard. |   |

## PRIORITY & SEQUENCING

| Keyword | Meaning | Notes |
| --- | --- | --- |
| `BEFORE` `<step>` / `AFTER` `<step>` | Ordering constraints. | (e.g. "`BEFORE` X do Y", "`AFTER` X do Y", etc...) |
| `PREFER` `<option>` `OVER` / `TO` `<option>` | Indicates preference. |   |
| `<option>` `TAKES PRECEDENCE OVER` / `OVERRIDES` `<option>` | Overwrites preference. |   |
| `IN` [`PRIORITY`] `ORDER`: `<option>`, `<option>`, ... | Sets order. |   |
| `FALL BACK TO` `<option>` | Sets preference when preferred option is unavailable. |   |

## SCOPE & EXCEPTIONS

| Keyword | Meaning | Notes |
| --- | --- | --- |
| `ONLY` | Limits scope to something |   |
| `ALL` [`<category>`] | Expands scope to include set |   |
| `EXCEPT` | Removes from scope |   |
| `LIMIT TO` | Sets boundaries on the extent |   |
| `FOR` `<case>` | Scope to specific case |   |
