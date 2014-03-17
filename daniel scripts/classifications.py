########## ClassificationUri ##########
def zeroStr(str, num):
  if num > 0:
    return zeroStr("0" + str, num - 1)
  return str

# pads an AAT code
def padAATCode(code):
  AATCodeLen = 9
  codeLen = len(code)
  if codeLen == AATCodeLen:
    return code
  # subtract 1 because the first digit is always three
  numZeroes = AATCodeLen - codeLen - 1
  return "3" + zeroStr("", numZeroes) + code

import re

# replace all special characters with an underscore
def urify(str):
  str = re.sub(r'[^!#$&amp;*+\--:=\?-\[\]_a-z~]+', '_', str.lower())
  # eliminate trailing underscores
  if str[len(str) - 1] == "_":
    str = str[:len(str) - 1]
  return str
	
if int(getValue("ObjectID")) > 0:
  if getValue("AATCN") == "AAT":
    return "http://vocab.getty.edu/aat/" + padAATCode(getValue("AATID"))
  else:
	return "http://collection.britishart.yale.edu/id/thesauri/collection/" + urify(getValue("Classification"))
return "";
########## END ClassificationUri END ##########




