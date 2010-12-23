//  (C) Copyright Gennadiy Rozental 2001-2004.
//  Distributed under the Boost Software License, Version 1.0.
//  (See accompanying file LICENSE_1_0.txt or copy at 
//  http://www.boost.org/LICENSE_1_0.txt)

//  See http://www.boost.org/libs/test for the library home page.
//
//  File        : $RCSfile: auto_unit_test_test.cpp,v $
//
//  Version     : $Revision: 1.8 $
//
//  Description : unit test for auto unit test facility
// ***************************************************************************

// Boost.Test
#define BOOST_AUTO_TEST_MAIN
#include <boost/test/auto_unit_test.hpp>

BOOST_AUTO_UNIT_TEST( test1 )
{
    BOOST_CHECK( true );
}

BOOST_AUTO_UNIT_TEST( test2 )
{
    BOOST_CHECK( true );
}

//____________________________________________________________________________//

// ***************************************************************************
//  Revision History :
//  
//  $Log: auto_unit_test_test.cpp,v $
//  Revision 1.8  2004/05/27 06:30:48  rogeeff
//  no message
//
//  Revision 1.7  2004/05/21 06:26:10  rogeeff
//  licence update
//
//  Revision 1.6  2003/12/01 00:42:37  rogeeff
//  prerelease cleaning
//
// ***************************************************************************

// EOF
