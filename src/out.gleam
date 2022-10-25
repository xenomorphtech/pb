import pb_lite
import gleam/map
import gleam/dynamic
import gleam/list

pub fn get_string(data, tag) -> Result(String, Nil) {
  case map.get(data, tag) {
    Ok(pb_lite.Binary(x)) -> Ok(dynamic.unsafe_coerce(dynamic.from(x)))
    _ -> Error(Nil)
  }
}

pub fn get_int(data, tag) -> Result(Int, Nil) {
  case map.get(data, tag) {
    Ok(pb_lite.VarInt(x)) -> Ok(x)
    Ok(pb_lite.Int32(x)) -> Ok(x)
    Ok(pb_lite.Int64(x)) -> Ok(x)
    _ -> Error(Nil)
  }
}

pub fn get_group(data, tag) -> Result(map.Map(Int, pb_lite.ValueType), Nil) {
  case map.get(data, tag) {
    Ok(pb_lite.Group(x)) -> Ok(map.from_list(x))
    _ -> Error(Nil)
  }
}

pub fn serialize_varint(v) -> BitString {
  iolist_to_binary(serialize_varint1(v, []))
}

pub fn serialize_varint1(v, acc) -> List(BitString) {
  let rv = shr(v, 7)
  case rv {
    0 -> list.reverse([<<0:size(1), v:size(7)>>, ..acc])

    _ -> {
      let va = band(v, 127)
      serialize_varint1(rv, [<<1:size(1), va:size(7)>>, ..acc])
    }
  }
}

pub fn encode_varint(tag, v) -> List(BitString) {
  [encode_tag(tag, 1), serialize_varint(v)]
}

pub fn encode_int32(tag, v) -> List(BitString) {
  todo
  // [tag, v] 
}

pub fn encode_int64(tag, v) -> List(BitString) {
  todo
  // [tag, v] 
}

pub fn encode_binary(tag, v: BitString) -> List(BitString) {
  [tag, v]
}

pub fn encode_group(tag, v) -> List(BitString) {
  [encode_tag(tag, 1), encode_msg(v), encode_tag(tag, 1)]
}

pub fn encode_string(tag, v: String) -> List(BitString) {
  [tag, dynamic.unsafe_coerce(dynamic.from(v))]
}

external fn iolist_to_binary(List(BitString)) -> BitString =
  "erlang" "iolist_to_binary"

external fn shl(Int, Int) -> Int =
  "helper1" "f_bsl"

external fn shr(Int, Int) -> Int =
  "helper1" "f_bsr"

external fn band(Int, Int) -> Int =
  "helper1" "f_band"

//pub fn dtag_type(bin) {
//  case bin {
//    <<tag:size(5), ftype:size(3), r:binary>> ->
//      case band(tag, 16) {
//        16 -> {
//          try #(value, r) = dvarint(r)
//          let v = shl(value, 4) + band(tag, 0xF)
//          Ok(#(v, ftype, r))
//        }
//        _ -> Ok(#(tag, ftype, r))
//      }
//  }
//}

pub type Corpus {
  CORPUSUNSPECIFIED
  CORPUSUNIVERSAL
  CORPUSWEB
  CORPUSIMAGES
  CORPUSLOCAL
  CORPUSNEWS
  CORPUSPRODUCTS
  CORPUSVIDEO
}

pub fn show_corpus(a: Corpus) -> List(String) {
  [
    case a {
      CORPUSUNSPECIFIED -> "CORPUSUNSPECIFIED"
      CORPUSUNIVERSAL -> "CORPUSUNIVERSAL"
      CORPUSWEB -> "CORPUSWEB"
      CORPUSIMAGES -> "CORPUSIMAGES"
      CORPUSLOCAL -> "CORPUSLOCAL"
      CORPUSNEWS -> "CORPUSNEWS"
      CORPUSPRODUCTS -> "CORPUSPRODUCTS"
      CORPUSVIDEO -> "CORPUSVIDEO"
    },
  ]
}

pub fn encode_corpus(a: Corpus) -> BitString {
  <<>>
}

pub fn extract2_corpus(data, tag) -> Result(Corpus, Nil) {
  try asint = get_int(data, tag)
  case asint {
    0 -> Ok(CORPUSUNSPECIFIED)
    1 -> Ok(CORPUSUNIVERSAL)
    2 -> Ok(CORPUSWEB)
    3 -> Ok(CORPUSIMAGES)
    4 -> Ok(CORPUSLOCAL)
    5 -> Ok(CORPUSNEWS)
    6 -> Ok(CORPUSPRODUCTS)
    7 -> Ok(CORPUSVIDEO)

    _ -> Error(Nil)
  }
}

pub type SearchResponse {
  SearchResponse(something: String)
}

pub fn show_search_response(a: SearchResponse) -> List(String) {
  []
}

pub fn encode_search_response(a: SearchResponse) -> BitString {
  iolist_to_binary([])
}

pub fn decode_search_response(data: BitString) -> Result(SearchResponse, Nil) {
  try #(dec, _rest) = pb_lite.decode(data)
  let dec1 = map.from_list(dec)

  try res = extract_search_response(dec1)

  Ok(res)
}

pub fn extract_search_response(data) -> Result(SearchResponse, Nil) {
  try f1 = get_string(data, 1)

  Ok(SearchResponse(f1))
}

pub fn extract2_search_response(data, tag) -> Result(SearchResponse, Nil) {
  try g = get_group(data, tag)

  extract_search_response(g)
}

pub type SearchRequest {
  SearchRequest(
    query: String,
    page_number: Int,
    result_per_page: Int,
    corpus: Corpus,
    searched: SearchResponse,
  )
}

pub fn show_search_request(a: SearchRequest) -> List(String) {
  []
}

pub fn encode_search_request(a: SearchRequest) -> BitString {
  iolist_to_binary([])
}

pub fn decode_search_request(data: BitString) -> Result(SearchRequest, Nil) {
  try #(dec, _rest) = pb_lite.decode(data)
  let dec1 = map.from_list(dec)

  try res = extract_search_request(dec1)

  Ok(res)
}

pub fn extract_search_request(data) -> Result(SearchRequest, Nil) {
  try f1 = get_string(data, 1)
  try f2 = get_int(data, 2)
  try f3 = get_int(data, 3)
  try f4 = extract2_corpus(data, 4)
  try f5 = extract2_search_response(data, 5)

  Ok(SearchRequest(f1, f2, f3, f4, f5))
}

pub fn extract2_search_request(data, tag) -> Result(SearchRequest, Nil) {
  try g = get_group(data, tag)

  extract_search_request(g)
}
