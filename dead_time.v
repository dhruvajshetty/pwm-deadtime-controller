module dead_time #(
  parameter DEAD_CYCLES = 4
)(
  input  clk,
  input  rst,
  input  pwm_in,
  output reg hs_out,   // high side gate
  output reg ls_out    // low side gate
);

  reg pwm_prev;
  reg [3:0] dead_cnt;
  reg in_dead;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      hs_out   <= 0;
      ls_out   <= 0;
      dead_cnt <= 0;
      in_dead  <= 0;
      pwm_prev <= 0;
    end
    else begin
      pwm_prev <= pwm_in;

      
      if (pwm_in !== pwm_prev) begin
        hs_out  <= 0;
        ls_out  <= 0;
        dead_cnt <= 0;
        in_dead  <= 1;
      end

    
      else if (in_dead) begin
        if (dead_cnt >= DEAD_CYCLES - 1) begin
          in_dead  <= 0;
          hs_out   <= pwm_in;
          ls_out   <= ~pwm_in;
        end
        else
          dead_cnt <= dead_cnt + 1;
      end

      
      else begin
        hs_out <= pwm_in;
        ls_out <= ~pwm_in;
      end
    end
  end

endmodule
