module aes_encrypt
(
    input clk,
    input [127:0] data,
    input [255:0] key,
    output [127:0] cypher
);


//state matrix
wire [127:0] state;
assign state = data ^ key[255-:128];
//rounds
wire [127:0] sbox_sig[13:0];
wire [127:0] shifted_rows_sig[13:0];
wire [127:0] mix_col_sig[12:0];
reg [127:0] added_key_sig[13:0];
reg [255:0] rnd_key_sig[13:0];
wire [31:0] g_tr_sig[6:0];
wire [31:0] s_tr_sig[11:0];

//1st round
always@(posedge clk)
begin
    added_key_sig[0] <= state;
    rnd_key_sig[0] <= key;  
end
genvar rnd,i;
generate
    //middle rounds
    for(rnd = 0; rnd < 13; rnd = rnd+1)
    begin : rounds
        //make round key
        always@(posedge clk)
            rnd_key_sig[rnd+1][255-:128] = rnd_key_sig[rnd][127:0];
        if((rnd % 2) == 0)
        begin : g_transform
            g_transform g_transform_inst(rnd_key_sig[rnd][31:0], rnd/2, g_tr_sig[rnd/2]);
            always@(posedge clk)
            begin
                rnd_key_sig[rnd+1][127-:32] <= rnd_key_sig[rnd][255-:32] ^ g_tr_sig[rnd/2];
                rnd_key_sig[rnd+1][95-:32]  <= rnd_key_sig[rnd][223-:32] ^ rnd_key_sig[rnd][255-:32] ^ g_tr_sig[rnd/2];
                rnd_key_sig[rnd+1][63-:32]  <= rnd_key_sig[rnd][191-:32] ^ rnd_key_sig[rnd][223-:32] ^ rnd_key_sig[rnd][255-:32] ^ g_tr_sig[rnd/2];
                rnd_key_sig[rnd+1][31-:32]  <= rnd_key_sig[rnd][159-:32] ^ rnd_key_sig[rnd][191-:32] ^ rnd_key_sig[rnd][223-:32] ^ rnd_key_sig[rnd][255-:32] ^ g_tr_sig[rnd/2];  
            end
        end
        else 
        begin : sbox_transform
            sbox_32bit sbox_32bit_inst(rnd_key_sig[rnd][31:0], s_tr_sig[rnd]);
            always@(posedge clk)
            begin
                rnd_key_sig[rnd+1][127-:32] <= rnd_key_sig[rnd][255-:32] ^ s_tr_sig[rnd];
                rnd_key_sig[rnd+1][95-:32]  <= rnd_key_sig[rnd][223-:32] ^ rnd_key_sig[rnd][255-:32] ^ s_tr_sig[rnd];
                rnd_key_sig[rnd+1][63-:32]  <= rnd_key_sig[rnd][191-:32] ^ rnd_key_sig[rnd][223-:32] ^ rnd_key_sig[rnd][255-:32] ^ s_tr_sig[rnd];
                rnd_key_sig[rnd+1][31-:32]  <= rnd_key_sig[rnd][159-:32] ^ rnd_key_sig[rnd][191-:32] ^ rnd_key_sig[rnd][223-:32] ^ rnd_key_sig[rnd][255-:32] ^ s_tr_sig[rnd];  
            end
        end
        always@(posedge clk)
        begin
            
        end
      
        //sbox
        for(i = 127; i >= 0; i = i-8)
        begin : sbox
            sbox sbox_inst(added_key_sig[rnd][i-:8],sbox_sig[rnd][i-:8]);
        end
        //shift rows
        shift_rows shift_rows_inst(sbox_sig[rnd], shifted_rows_sig[rnd]);
        //mix columns
        mix_col mix_col_inst(shifted_rows_sig[rnd], mix_col_sig[rnd]);
        //add rnd key
        always@(posedge clk)
            added_key_sig[rnd+1] <= mix_col_sig[rnd] ^ rnd_key_sig[rnd][127:0];
    end
    //final round
    for(i = 127; i >= 0; i = i-8)
        begin : sbox
            sbox sbox_inst(added_key_sig[13][i-:8],sbox_sig[13][i-:8]);
        end
    shift_rows shift_rows_inst(sbox_sig[13], shifted_rows_sig[13]);
    assign cypher = shifted_rows_sig[13] ^ rnd_key_sig[13][127:0];

endgenerate

endmodule