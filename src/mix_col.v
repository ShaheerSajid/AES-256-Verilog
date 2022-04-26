module mix_col
(
    input [127:0] in,
    output[127:0] out
);

wire [127:0] state;
wire [127:0] state_out_comb;

assign state = in;

function [7:0] MultiplyByTwo;
	input [7:0] x;
	begin 
			if(x[7] == 1) MultiplyByTwo = ((x << 1) ^ 8'h1b);
			else MultiplyByTwo = x << 1; 
	end 	
endfunction

function [7:0] MultiplyByThree;
	input [7:0] x;
	begin 
			MultiplyByThree = MultiplyByTwo(x) ^ x;
	end 
endfunction
 

genvar i;
generate
for(i=0;i<=3;i=i+1) begin
    assign state_out_comb[ i*32+:8]  = MultiplyByTwo(state[(i*32)+:8])^(state[(i*32 + 8)+:8])^(state[(i*32 + 16)+:8])^MultiplyByThree(state[(i*32 + 24)+:8]);
    assign state_out_comb[(i*32 + 8)+:8] = MultiplyByThree(state[(i*32)+:8])^MultiplyByTwo(state[(i*32 + 8)+:8])^(state[(i*32 + 16)+:8])^(state[(i*32 + 24)+:8]);
    assign state_out_comb[(i*32 + 16)+:8] = (state[(i*32)+:8])^MultiplyByThree(state[(i*32 + 8)+:8])^MultiplyByTwo(state[(i*32 + 16)+:8])^(state[(i*32 + 24)+:8]);
    assign state_out_comb[(i*32 + 24)+:8]  = (state[(i*32)+:8])^(state[(i*32 + 8)+:8])^MultiplyByThree(state[(i*32 + 16)+:8])^MultiplyByTwo(state[(i*32 + 24)+:8]);
end
endgenerate

assign out = state_out_comb;

endmodule