//********************************************************************************
// SPDX-License-Identifier: Apache-2.0
// Copyright 2019 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//********************************************************************************

module ccm
(
   input          clk,
   input          rst_n,
                                            
   //DCCM ports
   input          dccm_wr_en,
   input          dccm_rd_en,
   input  [31:0]  dccm_wr_addr,
   input  [31:0]  dccm_rd_addr,
   input  [31:0]  dccm_wr_data,
   output [31:0] dccm_rd_data,
   input    [1:0]  store_type,
   input    [1:0]  store_offset,

   //ICCM ports
   input  [31:0]  iccm_rd_addr,
   input          iccm_rd_en,
   output [31:0] iccm_rd_data
);
   

   // DCCM Instantiation
      dccm_mem dccm (
	  .*
      );

   	iccm_mem iccm (
	   .*
      );
  
endmodule

