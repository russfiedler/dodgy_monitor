program test_caller

use mpi
use dodgy_monitor_modules


integer :: its,secs=3
character(len=6) :: sleeptime


call mpi_init(ierr)

call dodgy_init

do its = 1,10
   write(sleeptime,'(f6.3)') 1.*its
   write(*,*) 'Waiting ',trim(sleeptime), 'for this segment'
   call dodgy_seg_start(secs)
   call execute_command_line('sleep '//trim(sleeptime))
   call dodgy_seg_finish
enddo
call dodgy_end
call mpi_finalize(ierr)
end program test_caller

