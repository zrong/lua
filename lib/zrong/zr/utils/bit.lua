local has_bitop, bit = pcall(require, 'bit')
if not has_bitop then
    import('...luabit.bit')
end
