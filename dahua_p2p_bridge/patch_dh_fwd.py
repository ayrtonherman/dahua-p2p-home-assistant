from pathlib import Path

helpers = Path("core/helpers.go")
s = helpers.read_text()
old = '''\treturn fmt.Sprintf(
\t\t"<CreateDate>%d</CreateDate><DevAuth>%s</DevAuth><Nonce>%d</Nonce><RandSalt>%s</RandSalt><UserName>%s</UserName>",
\t\tcreated, auth, nonce, salt, username,
\t)
'''
new = '''\trandSaltTag := ""
\tif salt != "" {
\t\trandSaltTag = fmt.Sprintf("<RandSalt>%s</RandSalt>", salt)
\t}
\treturn fmt.Sprintf(
\t\t"<CreateDate>%d</CreateDate><DevAuth>%s</DevAuth><Nonce>%d</Nonce>%s<UserName>%s</UserName>",
\t\tcreated, auth, nonce, randSaltTag, username,
\t)
'''
if old not in s:
    raise SystemExit("Patch failed: getAuthAt block not found")
helpers.write_text(s.replace(old, new, 1))

tunnel = Path("core/tunnel.go")
s = tunnel.read_text()
old = '''\tsalt, err := randsaltFromInfo(payload)
\tif err != nil {
\t\tif required {
\t\t\treturn "", fmt.Errorf("randsalt: %v", err)
\t\t}
\t\tlogf("%s profile: randsalt from the Info blob unavailable (%v) — continuing", prof.name, err)
\t\treturn randsalt, nil
\t}
'''
new = '''\tsalt, err := randsaltFromInfo(payload)
\tif err != nil {
\t\t// Some Dahua firmware returns HTTP 404 / an empty Info field for
\t\t// /info/device/<SN>. The reverse-engineered protocol documents these
\t\t// devices as legacy no-salt devices: derive the Type-1 key with an
\t\t// empty salt and omit the RandSalt XML element entirely.
\t\tif strings.Contains(err.Error(), "Info field absent") {
\t\t\tlogf("%s profile: device exposes no Info/RandSalt; using empty-salt Type-1 authentication", prof.name)
\t\t\treturn "", nil
\t\t}
\t\tif required {
\t\t\treturn "", fmt.Errorf("randsalt: %v", err)
\t\t}
\t\tlogf("%s profile: randsalt from the Info blob unavailable (%v) — continuing", prof.name, err)
\t\treturn randsalt, nil
\t}
'''
if old not in s:
    raise SystemExit("Patch failed: resolveAutoSalt block not found")
tunnel.write_text(s.replace(old, new, 1))
