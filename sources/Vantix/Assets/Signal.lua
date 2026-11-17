local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _handlers = {} }, Signal)
end

function Signal:Connect(fn)
    local conn = { _fn = fn, _signal = self, Connected = true }
    function conn:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        for i, v in ipairs(self._signal._handlers) do
            if v == self then table.remove(self._signal._handlers, i) break end
        end
    end
    conn.Destroy = conn.Disconnect
    table.insert(self._handlers, conn)
    return conn
end

function Signal:Fire(...)
    for _, conn in ipairs(self._handlers) do
        if conn.Connected then conn._fn(...) end
    end
end

function Signal:Wait()
    local thread = coroutine.running()
    local conn
    conn = self:Connect(function(...)
        conn:Disconnect()
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

function Signal:DisconnectAll()
    self._handlers = {}
end

Signal.Destroy = Signal.DisconnectAll

return Signal
