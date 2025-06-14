# Notes and Plaintexts for Selected Challenges

#### Challenge 3
Frequency analysis was performed prior to deciphering in order to find a character distribution for typical English text. The distribution used may be found in [/data/frequencies/text-en.txt](./data/frequencies/text-en.txt). The XOR cipher was decoded by evaluating the following expression in the Julia REPL:

    decode_single_byte_xor_ascii_bytes(Int64, "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736", "data/frequencies/text-en.txt")

and the part of the output containing the plaintext was

    PlaintextCandidate(0.48818607665007535, 0x5e, "Eiimoha&KE!u&jomc&g&vishb&i`&dgeih")
    PlaintextCandidate(0.48818607665007535, 0x7e, "eIIMOHA\x06ke\x01U\x06JOMC\x06G\x06VISHB\x06I@\x06DGEIH")
    PlaintextCandidate(0.5026654511411872, 0x58, "Cooking MC's like a pound of bacon")
    PlaintextCandidate(0.5026654511411872, 0x78, "cOOKING\0mc\aS\0LIKE\0A\0POUND\0OF\0BACON")
    PlaintextCandidate(0.5182717651886171, 0x52, "Ieeacdm*GI-y*fcao*k*ze\x7fdn*el*hkied")
    PlaintextCandidate(0.5182717651886171, 0x72, "iEEACDM\ngi\rY\nFCAO\nK\nZE_DN\nEL\nHKIED")

where `PlaintextCandidate = {score, key, candidate plaintext}` and scoring was done using the formula below.

    score = sum(abs(characteristic_distribution[k] - candidate_distribution[k]) for k in keys(candidate_distribution))

where `characteristic_distribution` is the character distribution of typical English text and `candidate_distribution` is the character distribution of the candidate plaintext. Here, `k` ranges over all the characters in the candidate plaintext and `distribution[k]` is the probability that a randomly chosen character in a text `T` is `k` if the characters of `T` are distributed according to `distribution`.

#### Challenge 4
Evaluate the expression

    identify_single_byte_xor_ascii_bytes(Int64, "data/ciphertexts/challenge-4.txt", "data/frequencies/text-en.txt", 256, 0.45, 0.75)

in the REPL to yield

    (274, PlaintextCandidate(0.450379956681759, 0x43, "{Xmet\eµ\x7f\x04\t_`ROn\x1c_aGQªS\0\eE\x15KOGd"))
    (274, PlaintextCandidate(0.450379956681759, 0x63, "[xMET;\u95_\$)\x7f@roN<\x7fAgq\u8as ;e5kogD"))
    (171, PlaintextCandidate(0.45042238491805614, 0x15, "nOW\0THAT\0THE\0PARTY\0IS\0JUMPING*"))
    (171, PlaintextCandidate(0.45042238491805614, 0x35, "Now that the party is jumping\n"))
    (4, PlaintextCandidate(0.45065253260051347, 0x55, "\x10\x11^BH\tNta{WIo[»&&t\t\x15q¥¾&i¥S·QY"))
    (4, PlaintextCandidate(0.45065253260051347, 0x75, "01~bh)nTA[wiO{\u9b\x06\x06T)5Q\u85\u9e\x06I\u85s\u97qy"

which reveals the plaintext. The ciphertext that generates the plaintext is thus the one on line 171 and the XOR key was `0x35`. The score range `[0.45, 0.75]` was chosen because short English text segments seem to have a score close to 0.5, although that assumption may have been incorrect in this case.

#### Challenge 5
Evaluate the expression below in the REPL.

    repeating_key_xor(Vector{UInt8}("Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"), Vector{UInt8}("ICE")) |> bytes2hex