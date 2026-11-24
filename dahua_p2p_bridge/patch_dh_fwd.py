#!/usr/bin/env python3
"""Small compatibility patch for Dahua firmware that answers /info/device with 404.

The DH-P2P reference implementation documents older/limited firmware that
provides no Info blob and therefore has no RandSalt. In that case Type-1
authentication uses the empty realm and omits the RandSalt XML element.
Some firmware returns HTTP 404 instead of an empty <Info/> element; allow the
same protocol fallback and let the authenticated p2p-channel response decide.
"""
from pathlib import Path

p = Path("core/tunnel.go")
s = p.read_text()
old = '''\tinfo := fields["Info"]
\tif info == "" {
\t\treturn "", fmt.Errorf("Info field absent")
\t}
'''
new = '''\tinfo := fields["Info"]
\tif info == "" {
\t\t// Some firmware has no device Info blob and therefore no RandSalt.
\t\t// Try the documented empty-realm Type-1 flow; the channel handshake
\t\t// will still reject invalid credentials or unsupported firmware.
\t\treturn "", nil
\t}
'''
assert old in s, "could not find randsaltFromInfo Info-field block"
s = s.replace(old, new, 1)
p.write_text(s)

p = Path("core/helpers.go")
s = p.read_text()
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
assert old in s, "could not find getAuthAt XML block"
s = s.replace(old, new, 1)
p.write_text(s)
print("Applied no-Info/empty-RandSalt compatibility patch.")
