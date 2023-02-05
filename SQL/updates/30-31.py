# Listen up.
# In order to run this script on Windows, you need to make sure you have Python **3** installed. Tested on 3.8.2
# It won't work on 2.7 at all.

# To run this, supply the following args in a command shell
# python 30-31.py address username password database table_old table_new
# Example:
# python 30-31.py localhost paradise ban_old ban

# !/usr/bin/env python3
import mysql.connector
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("address", help="MySQL server address (use localhost for the current computer)")
parser.add_argument("username", help="MySQL login username")
parser.add_argument("password", help="MySQL login password")
parser.add_argument("database", help="Database name")
parser.add_argument("curtable", help="Name of the current old ban table")
parser.add_argument("newtable", help="Name of the new bab table to insert to, can't be same as the source table")
parser.add_argument("port2server", help="Port to server name conversion instructions, expl: 7000:main,7001:secondary")
parser.add_argument("fallbackserver", help="Server name that will be set if port not present in port2server list")

args = parser.parse_args()
db = mysql.connector.connect(host=args.address, user=args.username, passwd=args.password, db=args.database)
cursor = db.cursor()
current_table = args.curtable
new_table = args.newtable
port2server = {}
fallback_server_name = args.fallbackserver

for pair in args.port2server.split(","):
    split = pair.split(":")
    if len(split) > 1:
        port2server[split[1]] = split[0]

for i in port2server:
    print("Port", i, "mapped to server", port2server[i])
print("Fallback server", fallback_server_name)

# Populate the target table with legacy data.
cursor.execute("SELECT id, bantime, serverip, bantype, reason, job, expiration_time, ckey, computerid, ip, a_ckey, a_computerid, a_ip,\
 who, adminwho, edits, unbanned, unbanned_datetime, unbanned_ckey, unbanned_computerid, unbanned_ip FROM {0}".format(current_table))

rows = cursor.fetchall()
print("Found", len(rows), "rows to parse.")

bans = []
type_stats = {"ADMIN_TEMPBAN": 0, "ADMIN_PERMABAN": 0, "TEMPBAN": 0, "PERMABAN": 0, "JOB_TEMPBAN": 0, "JOB_PERMABAN": 0, "APPEARANCE_BAN": 0}
server_stats = {}
lifted_bans = 0

for row in rows:
    ban_id = row[0]
    bantime = row[1]
    serverip = row[2]
    bantype = row[3]
    reason = row[4]
    job = row[5]
    expiration_time = row[6]
    ckey = row[7]
    computerid = row[8]
    ip = row[9]
    a_ckey = row[10]
    a_computerid = row[11]
    a_ip = row[12]
    who = row[13]
    adminwho = row[14]
    edits = row[15]
    unbanned = row[16]
    unbanned_datetime = row[17]
    unbanned_ckey = row[18]
    unbanned_computerid = row[19]
    unbanned_ip = row[20]

    address = serverip.split(":")
    server_address = address[0]
    server_port = "7000"

    if len(address) > 1:
        server_port = address[1]
    else:
        print("Error parsing port for ban id", ban_id)

    applied_to_admins = "0"
    is_global = "0"
    role = None

    if bantype == "ADMIN_TEMPBAN":
        applied_to_admins = "1"
        is_global = "1"
        role = "Server"
    elif bantype == "ADMIN_PERMABAN":
        applied_to_admins = "1"
        is_global = "1"
        role = "Server"
        expiration_time = None
    elif bantype == "TEMPBAN":
        role = "Server"
        expiration_time = None
    elif bantype == "PERMABAN":
        is_global = "1"
        role = "Server"
    elif bantype == "JOB_TEMPBAN":
        role = job
    elif bantype == "JOB_PERMABAN":
        role = job
        expiration_time = None
    elif bantype == "APPEARANCE_BAN":
        role = "Appearance"
        expiration_time = None
    else:
        print("Error parsing ban type for ban id", ban_id)
        continue

    if unbanned:
        lifted_bans += 1
    else:
        unbanned_datetime = None

    server_name = fallback_server_name

    if server_port in port2server.keys():
        server_name = port2server[server_port]

    type_stats[bantype] += 1

    if not server_name in server_stats:
        server_stats[server_name] = 0
    server_stats[server_name] += 1

    ban_obj = {"id": ban_id, "bantime": bantime, "server_ip": server_address, "server_port": server_port, "role": role,
               "expiration_time": expiration_time, "applies_to_admins": applied_to_admins, "reason": reason,
               "ckey": ckey, "ip": ip, "computerid": computerid, "a_ckey": a_ckey, "a_ip": a_ip,
               "a_computerid": a_computerid, "who": who, "adminwho": adminwho, "edits": edits,
               "unbanned_datetime": unbanned_datetime, "unbanned_ckey": unbanned_ckey, "unbanned_ip": unbanned_ip,
               "unbanned_computerid": unbanned_computerid, "server": server_name, "is_global": is_global}

    bans.append(ban_obj)

print("Assembled objects for", len(bans), "bans")
print("-----------------")
print("Temp server bans", type_stats["TEMPBAN"])
print("Temp job bans", type_stats["JOB_TEMPBAN"])
print("Permanent server bans", type_stats["PERMABAN"])
print("Permanent job bans", type_stats["JOB_PERMABAN"])
print("Temp admin bans", type_stats["ADMIN_TEMPBAN"])
print("Permanent admin bans", type_stats["ADMIN_PERMABAN"])
print("Permanent appearance bans", type_stats["APPEARANCE_BAN"])
print("-----------------")
for i in server_stats:
    print("Bans for server", i, server_stats[i])
print("-----------------")
print("Lifted bans", lifted_bans)
print("-----------------")

for ban in bans:
    cursor.execute("SELECT EXISTS(SELECT id FROM {0} WHERE id = {1})".format(new_table, ban["id"]))
    exists = cursor.fetchone()[0]
    if not exists:
        args = (ban["id"], ban["bantime"], ban["server_ip"], ban["server_port"], ban["role"], ban["expiration_time"],
                ban["applies_to_admins"], ban["reason"], ban["ckey"], ban["ip"], ban["computerid"], ban["a_ckey"],
                ban["a_ip"], ban["a_computerid"], ban["who"], ban["adminwho"], ban["edits"], ban["unbanned_datetime"],
                ban["unbanned_ckey"], ban["unbanned_ip"], ban["unbanned_computerid"], ban["server"], ban["is_global"])
        query = "INSERT INTO {0} (id, bantime, server_ip, server_port, role, expiration_time, applies_to_admins, reason, ckey, ip, computerid,\
a_ckey, a_ip, a_computerid, who, adminwho, edits, unbanned_datetime, unbanned_ckey, unbanned_ip, unbanned_computerid, server, is_global) \
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)".format(new_table)
        cursor.execute(query, args)
    else:
        print("WARNING: Ban with id", ban["id"], "already exists")

cursor.close()
db.commit()
