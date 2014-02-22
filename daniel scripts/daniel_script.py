# returns the uri for the given object ID
if int(getValue("ObjectID")) > 0:
	return "http://collection.britishart.yale.edu/id/" + getValue("ObjectID");
return "";

# this code returns the uri for collection based on the vocabulary where the 
#   collection is defined
import re

def urify(str):
	return re.sub(r'"\s+"', '-', str.lower())

source = getValue("AATCN")
uri = ""
if int(getValue("ObjectID")) > 0:
	if re.search(source, "AAT", re.IGNORECASE):
		uri = "http://vocab.getty.edu/aat/" + getValue("AATID")
	else:
		uri = "http://collection.britishart.yale.edu/id/thesauri/collection/" + urify(getValue("Classification"))

return uri

# this code returns the inscheme uri for the given collection
import re

source = getValue("AATCN")
uri = ""
if int(getValue("ObjectID")) > 0:
	if re.search(source, "AAT", re.IGNORECASE):
		uri = "http://vocab.getty.edu/aat/300000000"
	else:
		uri = "http://collection.britishart.yale.edu/id/thesauri/collection/"

return uri

####
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

return padAATCode(getValue("TMstID"))
