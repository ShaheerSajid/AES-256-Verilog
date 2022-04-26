module shift_rows
(
    input [127:0] in,
    output[127:0] out
);

//col0
assign out[127-:8] = in[127-:8];
assign out[119-:8] = in[87-:8];
assign out[111-:8] = in[47-:8];
assign out[103-:8] = in[7:0];
//col1
assign out[95-:8] = in[95-:8];
assign out[87-:8] = in[55-:8];
assign out[79-:8] = in[15-:8];
assign out[71-:8] = in[103-:8];
//col2
assign out[63-:8] = in[63-:8];
assign out[55-:8] = in[23-:8];
assign out[47-:8] = in[111-:8];
assign out[39-:8] = in[71-:8];
//col3
assign out[31-:8] = in[31-:8];
assign out[23-:8] = in[119-:8];
assign out[15-:8] = in[79-:8];
assign out[7-:8]  = in[39-:8];


endmodule