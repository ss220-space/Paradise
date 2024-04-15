#Updating the SQL from version 33 to version 34. -alffd
#Uplink items count
CREATE TABLE `uplink_items_buy` (
  `item` varchar(100) NOT NULL,
  `lasttime` datetime NOT NULL,
  `buyed` int(11) NOT NULL DEFAULT '0',
  `bydiscount` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`item`),
  UNIQUE KEY `item_UNIQUE` (`item`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
