import xml.etree.ElementTree as elemTree
import sys 
 
gamelistdoc = elemTree.parse(sys.argv[2] + '/gamelist.xml')
 
gameListElement = gamelistdoc.getroot()

#print(sys.argv[1])

newGameElement = elemTree.fromstring(sys.argv[1])
#ns={'xsi':'http://www.w3.org/2001/XMLSchema-instance'}
 
gameListElement.append(newGameElement)
#gamelistdoc.register_namespace('xsi','http://www.w3.org/2001/XMLSchema-instance')
gamelistdoc.write(sys.argv[2]+'/gamelist.xml',encoding="UTF-8",xml_declaration=True)
