`timescale 1ns/1ps

module tb_pwm;

  // Parameters
  parameter CNT_WIDTH  = 8;
  parameter DEAD_CYCLES = 4;

  // Inputs
  reg clk, rst;
  reg [CNT_WIDTH-1:0] duty, period;

  // Wires
  wire pwm_out;
  wire hs_out, ls_out;

  //PWM generator
  pwm_gen #(.CNT_WIDTH(CNT_WIDTH)) u_pwm (
    .clk(clk),
    .rst(rst),
    .duty(duty),
    .period(period),
    .pwm_out(pwm_out)
  );

  //dead-time module
  dead_time #(.DEAD_CYCLES(DEAD_CYCLES)) u_dt (
    .clk(clk),
    .rst(rst),
    .pwm_in(pwm_out),
    .hs_out(hs_out),
    .ls_out(ls_out)
  );

  // Clock: 10ns period = 100MHz
  initial clk = 0;
  always #5 clk = ~clk;

  // Shoot-through checker — runs continuously
  always @(posedge clk) begin
    if (hs_out === 1 && ls_out === 1) begin
      $display("FAIL: Shoot-through detected at time %0t", $time);
      $finish;
    end
  end

  // Stimulus
  initial begin
    // Dump waveform
    $dumpfile("pwm_wave.vcd");
    $dumpvars(0, tb_pwm);

    // Reset
    rst = 1; duty = 0; period = 0;
    #20;
    rst = 0;

    // Test 1: 50% duty cycle
    period = 100; duty = 50;
    $display("Test 1: 50%% duty cycle");
    #5000;

    // Test 2: 25% duty cycle
    duty = 25;
    $display("Test 2: 25%% duty cycle");
    #5000;

    // Test 3: 75% duty cycle
    duty = 75;
    $display("Test 3: 75%% duty cycle");
    #5000;

    // Test 4: Edge case — 0% duty
    duty = 0;
    $display("Test 4: 0%% duty cycle");
    #2000;

    // Test 5: Edge case — 100% duty
    duty = 100; period = 100;
    $display("Test 5: 100%% duty cycle");
    #2000;

    $display("ALL TESTS PASSED — No shoot-through detected");
    $finish;
  end

endmodule
