########## ObjectUri ##########
objectID = getValue("objectID")
if re.search('(subjectConcept)', getValue("thesxreftype")) and int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID;
return "";
########## END ObjectUri END ##########

########## SubjectTermUri ##########
# returns a string with the given number of zeroes
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

source = getValue("UCTS")
uri = ""
if re.search('(subjectConcept)', getValue("thesxreftype")) and int(getValue("objectID")) > 0:
	if re.search(source, "AAT", re.IGNORECASE):
		uri = "http://vocab.getty.edu/aat/" + padAATCode(getValue("TMstID"))
	else:
		uri = "http://collection.britishart.yale.edu/id/thesauri/subject/" + urify(getValue("Term"))

return uri
########## END SubjectTermUri END ##########

########## SubjectTermInScheme ##########
#
import re

source = getValue("UCTS")
uri = ""
if re.search(getValue("thesxreftype"), "subjectConcept") and int(getValue("objectID")) > 0:
 if re.search(source, "AAT", re.IGNORECASE):
  uri = "http://vocab.getty.edu/aat/300000000/"
 else:
  uri = "http://collection.britishart.yale.edu/id/thesauri/subject/"

return uri
########## END SubjectTermInScheme END ##########

