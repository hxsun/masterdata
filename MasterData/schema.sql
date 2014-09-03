-- phpMyAdmin SQL Dump
-- version 4.2.5
-- http://www.phpmyadmin.net
--
-- Host: localhost:8889
-- Generation Time: Sep 02, 2014 at 06:17 AM
-- Server version: 5.5.38
-- PHP Version: 5.5.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `car_usage`
--

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--

CREATE TABLE `brands` (
  `id` int(11) NOT NULL,
  `isSubbrand` tinyint(1) NOT NULL DEFAULT '0',
  `logoURL` varchar(256) NOT NULL,
  `name` varchar(256) NOT NULL,
  `origName` varchar(256) NOT NULL,
  `pinyinName` varchar(256) NOT NULL,
  `parentBrand` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `brands`
--

INSERT INTO `brands` (`id`, `isSubbrand`, `logoURL`, `name`, `origName`, `pinyinName`, `parentBrand`) VALUES
(1, 0, 'volkswagen', '大众', 'volkswagen', 'dazhong', 0),
(15, 0, 'bmw', '宝马', 'bmw', 'baoma', 0),
(18, 1, 'volkswagen', '一汽-大众', 'volkswagen', 'dazhong', 1),
(33, 0, 'audi', '奥迪', 'audi', 'aodi', 0),
(52, 0, 'lexus', '雷克萨斯', 'lexus', 'leikesasi', 0),
(150, 1, 'volkswagen', '大众(进口)', 'volkswagen', 'dazhong', 1),
(158, 1, 'volkswagen', '上海大众', 'volkswagen', 'dazhong', 1),
(339, 1, 'audi', '一汽-大众奥迪', 'audi', 'aodi', 33),
(1529, 1, 'bmw', '华晨宝马', 'bmw', 'baoma', 15),
(1580, 1, 'bmw', '宝马(进口)', 'bmw', 'baoma', 15),
(3379, 1, 'audi', '奥迪(进口)', 'audi', 'aodi', 33),
(15345, 1, 'bmw', '宝马M', 'bmw', 'baoma', 15),
(33346, 1, 'audi', '奥迪RS', 'audi', 'aodi', 33);

-- --------------------------------------------------------

--
-- Table structure for table `cars`
--

CREATE TABLE `cars` (
  `id` int(11) NOT NULL,
  `boughtDate` date NOT NULL,
  `addedDate` date NOT NULL,
  `deleted` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `components`
--

CREATE TABLE `components` (
  `id` int(11) NOT NULL,
  `name` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `maintenanceHistory`
--

CREATE TABLE `maintenanceHistory` (
  `location` blob NOT NULL,
  `id` int(11) NOT NULL,
  `mileage` int(11) NOT NULL,
  `updateDate` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `models`
--

CREATE TABLE `models` (
  `id` int(11) NOT NULL,
  `name` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `series`
--

CREATE TABLE `series` (
  `id` int(11) NOT NULL,
  `name` varchar(256) NOT NULL,
  `rank` varchar(256) NOT NULL,
  `brandId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `series`
--

INSERT INTO `series` (`id`, `name`, `rank`, `brandId`) VALUES
(112, '雷克萨斯GX', '中大型SUV', 52),
(201, '雷克萨斯IS', '中型车', 52),
(261, '雷克萨斯GS', '中大型车', 52),
(332, '雷克萨斯SC', '跑车', 52),
(341, '雷克萨斯LS', '豪华车', 52),
(351, '雷克萨斯RX', '中型SUV', 52),
(352, '雷克萨斯LX', '中大型SUV', 52),
(403, '雷克萨斯ES', '中大型车', 52),
(697, '雷克萨斯LFA', '跑车', 52),
(2063, '雷克萨斯CT', '紧凑型车', 52),
(3238, '雷克萨斯RC', '跑车', 52),
(3442, '雷克萨斯NX', '紧凑型车', 52);

-- --------------------------------------------------------

--
-- Table structure for table `updateHistory`
--

CREATE TABLE `updateHistory` (
  `mileage` int(11) NOT NULL,
  `updatedate` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `brands`
--
ALTER TABLE `brands`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `series`
--
ALTER TABLE `series`
 ADD PRIMARY KEY (`id`);
