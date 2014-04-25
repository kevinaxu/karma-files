#############################
# EXHIBITONS 
# File: ExhibitDates.csv
# Kevin Xu
# 4/17/14
#############################

########## ObjectUri ##########
objectID = getValue("ObjectID")
if int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID
return ""

# Exhibition URI
eventID = getValue("ObjectID")
if int(eventID) > 0:
    return "http://collection.britishart.yale.edu/id/exhibition/" + eventID
return ""

########## ExhibitionType ##########
objectID = getValue("ObjectID")
if int(objectID) > 0: 
    return "http://collection.britishart.yale.edu/id/thesauri/event/type/exhibition/" + objectID
return ""

######## Exhibition inScheme
objectID = getValue("ObjectID")
if int(objectID) > 0: 
    return "http://collection.britishart.yale.edu/id/thesauri/person-institution"
return ""

####### identified by
objectID = getValue("ObjectID")
if int(objectID) > 0: 
    return "http://collection.britishart.yale.edu/id/exhibition/" + objectID + "/TMS"
return ""








########## ObjectDimUri ##########
if int(getValue("ID")) > 0:
    return getValue("ObjectUri") + "/measurement/" + getValue("Rank")
return ""
########## END ObjectDimUri END ##########

########## ObjectDimTypeUri ##########
if int(getValue("ID")) > 0:
    return getValue("ObjectDimUri") + "/" + getValue("DimensionType")
return ""
########## END ObjectDimTypeUri END ##########

########## DimTypeThesauri ##########
import re
def urify(str):
    return re.sub(r'\s+', '-', str.lower())
if int(getValue("ID")) > 0:
    return "http://collection.britishart.yale.edu/id/thesauri/dimension/" + urify(getValue("DimensionType"))
return ""
########## END DimTypeThesauri END ##########

########## DimTypeInScheme ##########
if int(getValue("ID")) > 0:
    return "http://collection.britishart.yale.edu/id/thesauri/dimension/"
return ""
########## END DimTypeInScheme END ##########

########## ExtentThesauri ##########
import re
def urify(str):
    return re.sub(r'\s+', '-', str.lower())
if int(getValue("ID")) > 0:
    return "http://collection.britishart.yale.edu/id/thesauri/extent/" + urify(getValue("Element"))
return ""
########## END ExtentThesauri END ##########

########## ExtentInScheme ##########
if int(getValue("ID")) > 0:
    return "http://collection.britishart.yale.edu/id/thesauri/extent/"
return ""
########## END ExtentInScheme END ##########

########## DimensionTypeDup ##########
return getValue("DimensionType")
########## END DimensionTypeDup END ##########

########## DimensionUnit ##########
import re
qudtBase = "http://qudt.org/vocab/unit#"
if re.search('weight', getValue("DimensionType")):
	return qudtBase + "Kilogram"
return qudtBase + "Centimeter"
########## END DimensionUnit END ##########
