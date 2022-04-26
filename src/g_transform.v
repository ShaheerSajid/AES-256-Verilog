module g_transform
(
    input [31:0] in,
    input [3:0] rnd,
    output [31:0] out
);

//byte shift
wire [31:0] shifted;
assign shifted = {in[23:0], in[31:24]};
//sbox
wire [31:0] sbox_out;
sbox s1(shifted[7:0], sbox_out[7:0]);
sbox s2(shifted[15:8], sbox_out[15:8]);
sbox s3(shifted[23:16], sbox_out[23:16]);
sbox s4(shifted[31:24], sbox_out[31:24]);
//rcon xor
wire [31:0] rcon_out;
rcon r1(rnd,rcon_out);
assign out = sbox_out ^ rcon_out;

endmodule