-- includes
dofile(SOAPBOX_FREEROAM_PATH .. "soapbox-packet-types.lua") -- packet type detection
dofile(SOAPBOX_FREEROAM_PATH .. "soapbox-dissector-hello.lua") -- hello protocol
dofile(SOAPBOX_FREEROAM_PATH .. "soapbox-dissector-pos.lua") -- pos protocol

-- create freeroam protocol
p_freeroam = Proto("freeroam", "Soapbox-race freeroam")

-- create fields
f_fr_pkt_dir = ProtoField.uint16("freeroam.pktdir", "Packet Direction", base.BOOLEAN)
f_fr_crc = ProtoField.uint16("freeroam.crc", "CRC", base.HEX)
f_fr_pid = ProtoField.uint16("freeroam.pid", "PID", base.UINT16)
f_fr_pos = ProtoField.string("freeroam.pos", "Position (X,Y,Z)", base.UNIT_STRING)
f_fr_pname = ProtoField.string("freeroam.pname", "Persona Name", base.UNIT_STRING)
f_fr_channel = ProtoField.string("freeroam.channel", "Chat Channel", base.UNIT_STRING)

-- protocol setup (add fields)
p_freeroam.fields = {
    f_fr_pkt_dir, -- packet direction
    f_fr_crc, -- packet crc
    f_fr_pid, -- packet pid
    f_fr_pname, -- packet pname
    f_fr_channel, -- packet channel
    f_fr_pos, -- packet pos
}

-- freeroam dissector function
function p_freeroam.dissector(buf, pkt, root)
    -- validate packet length is adequate, otherwise quit
    if buf:len() == 0 then return end

    pkt.cols.protocol = "NFSW-FR"
    local subtree = root:add(p_freeroam, buf(0));
    setFieldsFromType(buf, pkt, subtree)
    subtree:append_text(" | Direction: " .. detectDirection(pkt))
    subtree:add(f_fr_crc, buf(buf:len() - 4, 4))
end

-- Initialization
function p_freeroam.init()
end

-- register the dissector for port 9999
local udp_dissector_table = DissectorTable.get("udp.port")
dissector = udp_dissector_table:get_dissector(9999)
udp_dissector_table:add(9999, p_freeroam)

