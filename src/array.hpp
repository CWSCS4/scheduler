
// array.hpp

// Copyright 2004 Jeremy Bertram Maitin-Shepard.

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License Version
// 2 as published by the Free Software Foundation.

// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA

#ifndef CWS_ARRAY_HPP_INCLUDED
#define CWS_ARRAY_HPP_INCLUDED

#include <cassert>

namespace cws
{
  template <class T>
  class Array
  {
  private:
    T *data_;
    int size_;
  public:

    typedef T value_type;
    typedef T &reference;
    typedef const T &const_reference;
    typedef T *pointer;
    typedef const T *const_pointer;
    typedef int size_type;
    typedef int difference_type;
    typedef pointer iterator;
    typedef const_pointer const_iterator;

    Array()
      : size_(0) {data_ = 0;}
    Array(int size)
      : size_(size) {data_ = new T[size_];}
    Array(const Array &a)
      : size_(a.size())
    {
      data_ = new T[size_];
      for (int i = 0; i < size_; ++i)
        data_[i] = a.data_[i];
    }

    Array &operator=(const Array &a)
    {
      if (size_ != a.size_)
      {
        delete[] data_;
        data_ = new T[a.size_];
      }
      size_ = a.size_;
      for (int i = 0; i < size_; ++i)
        data_[i] = a.data_[i];
      return *this;
    }

    void initialize(int size)
    {
      delete[] data_;
      size_ = size;
      data_ = new T[size_];
    }

    bool operator==(const Array &a) const
    {
      if (a.size() != size())
        return false;
      for (int i = 0; i < size_; ++i)
        if (data_[i] != a.data_[i])
          return false;
      return true;
    }

    bool operator!=(const Array &a) const
    {
      return !(*this == a);
    }
      
    ~Array() {delete[] data_;}
    T &operator[](int i)
    {
      assert(i >= 0 && i < size_);
      return data_[i];
    }
    const T &operator[](int i) const
    {
      assert(i >= 0 && i < size_);
      return data_[i];
    }
    T *data() {return data_;}
    T *begin() {return data_;}
    T *end() {return data_ + size_;}
    const T *begin() const {return data_;}
    const T *end() const {return data_ + size_;}
    const T *data() const {return data_;}
    int size() const {return size_;}
    bool empty() const {return size_ == 0;}
    
  };
  
} // namespace cws

#endif // CWS_ARRAY_HPP_INCLUDED
