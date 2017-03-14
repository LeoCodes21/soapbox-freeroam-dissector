-- Determines packet direction.
-- If the packet was *sent* to port 9999, then
-- it's a client->server packet. If it was *received*
-- from port 9999, then it's a server->client packet.
-- Not sure if there's any better way to do this.
function detectDirection(pkt)
    -- temporary "hack" to determine direction
    -- if dst_port == 9999, then it's c->s
    -- otherwise, if src_port == 9999, then it's s->c
    -- otherwise, unknown

    if pkt.dst_port == 9999 then
        return "C->S"
    elseif pkt.src_port == 9999 then
        return "S->C"
    end
end

-- Determines the type of a packet
-- Possible types:
--     Client: hello, pos, sync???
--     Server: hello-ok, modified-pos
-- There may be more.
-- Returns structure: { dir: 'c->s' or 's->c', type: 'typehere' }
function determineType(buf, pkt)
    -- Bytes
    local bytes = buf(0):bytes()

    -- Struct setup
    local struct = {
        dir = detectDirection(pkt),
        type = ''
    }

    if bytes:len() > 1 then
        local subset = bytes:subset(2, 1)

        if subset == ByteArray.new("06") then -- 3rd byte 0x06 == hello
            struct.type = 'hello'
        elseif subset == ByteArray.new("07") and bytes:len() >= 65 then
            struct.type = 'pos'
        end
    end

    return struct;
end

-- Sets the appropriate fields from a given packet.
function setFieldsFromType(buf, pkt, root)
    local result = determineType(buf, pkt)

    if result.type == 'hello' then
        setHelloFields(buf, pkt, root)
    elseif result.type == 'pos' then
        setPosFields(buf, pkt, root)
    end
end

function setPersonaIdField(subtree, pid)
    subtree:add(f_fr_pid, pid)
end