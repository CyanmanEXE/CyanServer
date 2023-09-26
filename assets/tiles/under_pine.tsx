<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.8" tiledversion="1.8.0" name="Nature - Undernet Pine" tilewidth="64" tileheight="67" tilecount="4" columns="4" objectalignment="bottom">
 <tileoffset x="0" y="16"/>
 <grid orientation="isometric" width="64" height="32"/>
 <properties>
  <property name="Solid" type="bool" value="true"/>
 </properties>
 <image source="under_pine.png" width="256" height="67"/>
 <tile id="0">
  <objectgroup draworder="index" id="2">
   <object id="1" x="-1" y="-1" width="34" height="34">
    <ellipse/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="0" duration="200"/>
   <frame tileid="1" duration="200"/>
   <frame tileid="2" duration="200"/>
   <frame tileid="3" duration="200"/>
   <frame tileid="2" duration="200"/>
   <frame tileid="1" duration="200"/>
  </animation>
 </tile>
</tileset>
